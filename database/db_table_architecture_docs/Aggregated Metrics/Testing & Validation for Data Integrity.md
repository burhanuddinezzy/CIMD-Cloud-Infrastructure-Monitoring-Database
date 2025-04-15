# Testing & Validation for Data Integrity

To ensure the **accuracy, reliability, and completeness** of the `aggregated_metrics` table, rigorous **testing and validation mechanisms** are required. These include **cross-verification with raw data**, **handling missing or inconsistent values**, and **automated checks for anomalies**.

---

### **1. Cross-Checking Aggregated Metrics Against Raw Data**

**Why It Matters?**

- Ensures that **aggregated values (averages, peaks, etc.) correctly reflect raw server metrics**.
- Prevents **incorrect summarization** that could **mislead performance analysis**.

**How It Works?**

- **Validate `hourly_avg_cpu_usage`** by comparing it against **actual CPU readings** stored in `server_metrics`.
- **Ensure `peak_disk_usage` and `peak_network_usage`** correctly represent the **maximum observed values** in a given hour.

**Implementation:**

- **Test query to validate average CPU calculation:**
    
    ```sql
    sql
    CopyEdit
    SELECT a.server_id,
           a.hourly_avg_cpu_usage AS aggregated_value,
           ROUND(AVG(s.cpu_usage), 2) AS raw_calculated_value
    FROM aggregated_metrics a
    JOIN server_metrics s ON a.server_id = s.server_id
    WHERE s.timestamp >= NOW() - INTERVAL '1 hour'
    GROUP BY a.server_id, a.hourly_avg_cpu_usage
    HAVING ABS(a.hourly_avg_cpu_usage - ROUND(AVG(s.cpu_usage), 2)) > 0.5;
    
    ```
    
- **Test query to verify peak network usage:**
    
    ```sql
    sql
    CopyEdit
    SELECT a.server_id,
           a.peak_network_usage AS aggregated_value,
           MAX(s.network_usage) AS raw_calculated_value
    FROM aggregated_metrics a
    JOIN server_metrics s ON a.server_id = s.server_id
    WHERE s.timestamp >= NOW() - INTERVAL '1 hour'
    GROUP BY a.server_id, a.peak_network_usage
    HAVING a.peak_network_usage != MAX(s.network_usage);
    
    ```
    

**Benefits:**

✅ **Ensures aggregated data reflects real-world performance metrics.**

✅ **Prevents incorrect data aggregation, reducing false alerts.**

---

### **2. Handling Missing or Incomplete Data**

**Why It Matters?**

- Missing raw data due to **network failures, system crashes, or logging errors** can lead to **inaccurate aggregations**.
- Ensures that **incomplete or partial data does not corrupt aggregated trends**.

**How It Works?**

- **Check for missing raw data** in `server_metrics` before aggregating.
- **Use interpolation techniques** to estimate missing values.
- **Trigger alerts for excessive missing data** instead of recording incorrect values.

**Implementation:**

- **Identify time periods with missing raw data:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, COUNT(*) AS missing_records
    FROM (
        SELECT generate_series(NOW() - INTERVAL '1 hour', NOW(), INTERVAL '1 minute') AS expected_time,
               server_id
        FROM server_metrics
        WHERE server_id IN (SELECT DISTINCT server_id FROM aggregated_metrics)
    ) expected_times
    LEFT JOIN server_metrics actual ON expected_times.expected_time = actual.timestamp
                                    AND expected_times.server_id = actual.server_id
    WHERE actual.timestamp IS NULL
    GROUP BY server_id
    HAVING COUNT(*) > 10;
    
    ```
    
- **Trigger alert if missing data is excessive:**
    
    ```sql
    sql
    CopyEdit
    CREATE OR REPLACE FUNCTION notify_missing_data() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.missing_records > 10 THEN
            PERFORM pg_notify('missing_data_alerts', json_build_object(
                'server_id', NEW.server_id,
                'missing_records', NEW.missing_records,
                'timestamp', NOW()
            )::TEXT);
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
    CREATE TRIGGER missing_data_trigger
    AFTER INSERT OR UPDATE ON aggregated_metrics
    FOR EACH ROW EXECUTE FUNCTION notify_missing_data();
    
    ```
    

**Benefits:**

✅ **Prevents missing data from distorting reports.**

✅ **Notifies system admins when data gaps exceed acceptable limits.**

---

### **3. Ensuring Peak Values Reflect True Maximums**

**Why It Matters?**

- If `peak_network_usage` or `peak_disk_usage` **does not reflect true maximums**, **spikes** in traffic or disk load **might go undetected**.
- Prevents incorrect thresholds from triggering **false positives or negatives** in alerting.

**How It Works?**

- **Cross-verify peak values with all recorded data points** to ensure they were captured correctly.
- **Ensure the time-series database is correctly indexing maximum values** for aggregation.

**Implementation:**

- **Validate peak disk usage calculation:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, peak_disk_usage AS stored_peak,
           MAX(disk_usage) AS actual_peak
    FROM aggregated_metrics
    JOIN server_metrics ON aggregated_metrics.server_id = server_metrics.server_id
    WHERE server_metrics.timestamp >= NOW() - INTERVAL '1 hour'
    GROUP BY server_id, peak_disk_usage
    HAVING stored_peak != actual_peak;
    
    ```
    
- **Correct incorrect peak values:**
    
    ```sql
    sql
    CopyEdit
    UPDATE aggregated_metrics a
    SET peak_disk_usage = (
        SELECT MAX(disk_usage)
        FROM server_metrics s
        WHERE s.server_id = a.server_id
        AND s.timestamp >= NOW() - INTERVAL '1 hour'
    )
    WHERE peak_disk_usage != (
        SELECT MAX(disk_usage)
        FROM server_metrics s
        WHERE s.server_id = a.server_id
        AND s.timestamp >= NOW() - INTERVAL '1 hour'
    );
    
    ```
    

**Benefits:**

✅ **Ensures peak values always reflect actual system load.**

✅ **Prevents anomalies from distorting alerts or performance analysis.**

---

### **4. Unit Testing for Aggregation Logic**

**Why It Matters?**

- Ensures **database functions, triggers, and stored procedures** process data correctly.
- Helps **validate schema integrity** across **different test scenarios**.

**How It Works?**

- **Simulate real-world data loads** and validate expected outputs.
- **Create test cases** for edge conditions (e.g., sudden CPU spikes, downtime events).

**Implementation:**

- **Unit test for CPU aggregation logic (using pgTAP for PostgreSQL testing)**
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM plan(3);
    
    -- Test that hourly CPU usage aggregates correctly
    SELECT is(
        (SELECT ROUND(AVG(cpu_usage),2)
         FROM server_metrics
         WHERE timestamp >= NOW() - INTERVAL '1 hour'),
        (SELECT hourly_avg_cpu_usage FROM aggregated_metrics
         WHERE timestamp >= NOW() - INTERVAL '1 hour'),
        'CPU usage aggregation is correct'
    );
    
    -- Test that peak network usage is correctly stored
    SELECT is(
        (SELECT MAX(network_usage)
         FROM server_metrics
         WHERE timestamp >= NOW() - INTERVAL '1 hour'),
        (SELECT peak_network_usage FROM aggregated_metrics
         WHERE timestamp >= NOW() - INTERVAL '1 hour'),
        'Network peak usage is correctly recorded'
    );
    
    -- Test that uptime percentage is within valid range (0-100)
    SELECT ok(
        (SELECT uptime_percentage BETWEEN 0 AND 100
         FROM aggregated_metrics WHERE timestamp >= NOW() - INTERVAL '1 hour'),
        'Uptime percentage is within valid range'
    );
    
    SELECT * FROM finish();
    
    ```
    

**Benefits:**

✅ **Prevents aggregation logic errors before deployment.**

✅ **Provides automated checks to validate schema integrity.**

---

### **Final Takeaways: Advanced Data Integrity Validation**

🚀 **Cross-check raw and aggregated data** to ensure accurate summarization.

🚀 **Detect and handle missing data** before it skews performance trends.

🚀 **Validate peak values** to prevent incorrect system load analysis.

🚀 **Use unit testing** to automate validation across different scenarios.

Would you like **automated anomaly detection scripts** to flag **unexpected performance trends** in real-time? 🚀