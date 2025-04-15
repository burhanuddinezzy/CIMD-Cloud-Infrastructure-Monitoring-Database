# How You Tested & Validated Data Integrity

### **1. Database Constraints & Validation**

- **Foreign key constraints** prevent orphaned records by ensuring relationships between tables are maintained.
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE error_logs ADD CONSTRAINT fk_server FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;
    
    ```
    
    - **Test:** Attempt to insert an `error_logs` entry with a `server_id` that does not exist in `server_metrics`. The database should reject the entry.
- **Check constraints** ensure that numeric values stay within valid ranges.
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics ADD CONSTRAINT chk_cpu_usage CHECK (cpu_usage BETWEEN 0 AND 100);
    
    ```
    
    - **Test:** Try inserting `cpu_usage = 120` and expect an error.

### **2. Data Type Validation**

- **Ensure correct data types are used** to prevent unexpected errors and performance issues.
    
    ```sql
    sql
    CopyEdit
    SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'server_metrics';
    
    ```
    
    - **Test:** Verify that `cpu_usage` is stored as `FLOAT`, `server_id` as `UUID`, and `timestamp` as `TIMESTAMP`.
- **Automated JSON Schema Validation** (if using `JSONB` storage)
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics ADD CONSTRAINT validate_json CHECK (
        metrics::jsonb ? 'cpu_usage' AND
        metrics->>'cpu_usage' ~ '^[0-9]+(\.[0-9]+)?$'
    );
    
    ```
    
    - **Test:** Try inserting malformed JSON and expect a constraint violation.

### **3. Data Integrity Testing with Sample Inserts**

- Insert test records and verify that constraints function as expected.
    
    ```sql
    sql
    CopyEdit
    INSERT INTO server_metrics (server_id, cpu_usage, memory_usage, timestamp)
    VALUES ('550e8400-e29b-41d4-a716-446655440000', 95.5, 70.2, now());
    
    ```
    
    - **Test:** Verify that invalid inserts (e.g., `cpu_usage = 150`) fail while valid ones succeed.

### **4. Referential Integrity Testing**

- **Test cascading deletes** to ensure foreign keys work properly.
    
    ```sql
    sql
    CopyEdit
    DELETE FROM server_metrics WHERE server_id = '550e8400-e29b-41d4-a716-446655440000';
    
    ```
    
    - **Expected Outcome:** Related records in `error_logs`, `alerts_history`, and `downtime_logs` should also be removed.

### **5. Unique & Index Constraints Testing**

- **Ensure `server_id` is unique** to avoid duplicate records.
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics ADD CONSTRAINT unique_server UNIQUE (server_id, timestamp);
    
    ```
    
    - **Test:** Try inserting two records with the same `server_id` and `timestamp`, expecting a failure.
- **Check indexing effectiveness** using `EXPLAIN ANALYZE` for query performance.
    
    ```sql
    sql
    CopyEdit
    EXPLAIN ANALYZE SELECT * FROM server_metrics WHERE server_id = '550e8400-e29b-41d4-a716-446655440000';
    
    ```
    
    - **Expected Outcome:** The query should use an `INDEX SCAN`, not `SEQUENTIAL SCAN`.

### **6. Automated Data Validation Scripts**

- **Python Script for Data Validation**
    
    ```python
    python
    CopyEdit
    import psycopg2
    
    conn = psycopg2.connect("dbname=mydb user=myuser password=mypassword")
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*) FROM server_metrics WHERE cpu_usage < 0 OR cpu_usage > 100")
    invalid_entries = cursor.fetchone()[0]
    
    assert invalid_entries == 0, f"Data integrity check failed: {invalid_entries} invalid records found."
    
    print("All data integrity checks passed.")
    
    ```
    
    - **Test:** Run the script regularly to catch invalid data early.

### **7. Cross-Table Consistency Checks**

- **Ensure downtime is logged when uptime is zero.**
    
    ```sql
    sql
    CopyEdit
    SELECT COUNT(*) FROM server_metrics sm
    LEFT JOIN downtime_logs dl ON sm.server_id = dl.server_id AND sm.timestamp = dl.timestamp
    WHERE sm.uptime_in_mins = 0 AND dl.server_id IS NULL;
    
    ```
    
    - **Expected Outcome:** Zero missing `downtime_logs` entries when `uptime_in_mins = 0`.
- **Verify that alerts are logged for high CPU usage.**
    
    ```sql
    sql
    CopyEdit
    SELECT COUNT(*) FROM server_metrics sm
    LEFT JOIN alerts_history ah ON sm.server_id = ah.server_id AND sm.timestamp = ah.timestamp
    WHERE sm.cpu_usage > 90 AND ah.server_id IS NULL;
    
    ```
    
    - **Expected Outcome:** Every high CPU event has a corresponding alert.

### **8. Data Consistency Through Transaction Testing**

- **Ensure atomicity with transactions** to prevent incomplete updates.
    
    ```sql
    sql
    CopyEdit
    BEGIN;
    
    UPDATE server_metrics SET cpu_usage = 95 WHERE server_id = '550e8400-e29b-41d4-a716-446655440000';
    INSERT INTO alerts_history (server_id, alert_type, created_at) VALUES ('550e8400-e29b-41d4-a716-446655440000', 'High CPU Usage', now());
    
    COMMIT;
    
    ```
    
    - **Test:** If either the update or insert fails, the entire transaction should roll back.

### **9. Anomaly Detection with Machine Learning**

- **Detect irregular patterns in data** to identify potential data corruption.
    
    ```python
    python
    CopyEdit
    import pandas as pd
    from sklearn.ensemble import IsolationForest
    
    df = pd.read_sql("SELECT cpu_usage, memory_usage, disk_read_ops_per_sec FROM server_metrics", conn)
    model = IsolationForest(contamination=0.01)
    df['anomaly'] = model.fit_predict(df)
    
    anomalies = df[df['anomaly'] == -1]
    print(anomalies)
    
    ```
    
    - **Test:** Identify abnormal data points and flag them for review.

### **10. Scheduled Integrity Checks & Logging**

- **Use cron jobs to periodically verify data integrity.**
    
    ```
    sh
    CopyEdit
    # Run validation script every hour
    0 * * * * python /scripts/data_integrity_check.py >> /logs/integrity_checks.log
    
    ```
    
    - **Test:** Ensure logs capture failed validation attempts for auditing.

### **Final Takeaways**

- **Foreign key constraints** and **check constraints** prevent common integrity issues.
- **Data type validation** ensures values are stored correctly.
- **Automated scripts and queries** detect anomalies and enforce rules.
- **Transaction testing** prevents incomplete or inconsistent updates.
- **Machine learning models** help detect irregular patterns.

Need help setting up **automated data integrity validation** for your system? 🚀