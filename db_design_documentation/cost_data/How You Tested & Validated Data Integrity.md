# How You Tested & Validated Data Integrity

Ensuring **data integrity** in cost tracking is crucial to prevent **billing errors, miscalculations, and inaccurate financial reporting**. Validation mechanisms were implemented at multiple levels to ensure consistency, accuracy, and reliability.

---

### **1. Enforcing Data Validity with Constraints**

**Why?** Prevents invalid, missing, or logically incorrect cost data from being inserted.

- **Check constraints ensure valid numerical values:**
    - `cost_per_hour` and `total_monthly_cost` **must be positive** to avoid incorrect or nonsensical financial records.
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE cost_data ADD CONSTRAINT check_positive_cost CHECK (cost_per_hour > 0 AND total_monthly_cost > 0);
    
    ```
    
    - Prevents accidental entry of **negative or zero costs**, which could indicate data corruption.
- **Foreign key constraints ensure cost records are linked to existing servers:**
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE cost_data ADD CONSTRAINT fk_server FOREIGN KEY (server_id) REFERENCES servers(server_id) ON DELETE CASCADE;
    
    ```
    
    - Ensures that costs are only logged for servers **that actually exist**.
    - **Cascading deletes** remove cost records if a server is decommissioned.
- **NOT NULL constraints ensure critical fields are always populated:**
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE cost_data
    ALTER COLUMN cost_per_hour SET NOT NULL,
    ALTER COLUMN total_monthly_cost SET NOT NULL;
    
    ```
    
    - Prevents missing data, ensuring all cost calculations are valid.

---

### **2. Detecting Data Anomalies with Test Queries**

**Why?** Identifies potential **errors, inconsistencies, or unexpected patterns** in cost data.

- **Detect servers with unexpectedly high costs (outliers):**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, cost_per_hour
    FROM cost_data
    WHERE cost_per_hour > (SELECT AVG(cost_per_hour) FROM cost_data) * 2;
    
    ```
    
    - If a server’s **cost per hour is more than 2× the average**, it may indicate **billing misconfiguration** or **incorrect allocations**.
- **Identify missing costs for active servers:**
    
    ```sql
    sql
    CopyEdit
    SELECT s.server_id
    FROM servers s
    LEFT JOIN cost_data c ON s.server_id = c.server_id
    WHERE c.server_id IS NULL;
    
    ```
    
    - Ensures that **every active server has a corresponding cost record**.
- **Validate consistency between cost data and resource usage:**
    
    ```sql
    sql
    CopyEdit
    SELECT c.server_id, c.total_monthly_cost, r.allocated_cpu
    FROM cost_data c
    JOIN resource_allocation r ON c.server_id = r.server_id
    WHERE c.total_monthly_cost > 10000 AND r.allocated_cpu < 2;
    
    ```
    
    - **Red flag:** A server with **low CPU allocation but high costs** may indicate **incorrect billing**.

---

### **3. Unit Testing & Automated Data Validation**

**Why?** Ensures **queries, constraints, and data processing logic** behave as expected.

- **Automated SQL tests using `pgTAP` (PostgreSQL testing framework):**
    - Example: Ensure `cost_per_hour` is always greater than zero.
        
        ```sql
        sql
        CopyEdit
        SELECT * FROM plan(1);
        SELECT hasnt_null('cost_data', 'cost_per_hour', 'cost_per_hour should never be NULL');
        SELECT isnt('cost_data.cost_per_hour', '<=', 0, 'cost_per_hour should always be positive');
        SELECT * FROM finish();
        
        ```
        
    - Automatically runs tests **before deploying schema updates**.
- **Python unit tests validate cost calculations:**
    
    ```python
    python
    CopyEdit
    import unittest
    import psycopg2
    
    class TestCostData(unittest.TestCase):
        def setUp(self):
            self.conn = psycopg2.connect("dbname=testdb user=testuser password=testpass")
            self.cur = self.conn.cursor()
    
        def test_positive_cost(self):
            self.cur.execute("SELECT COUNT(*) FROM cost_data WHERE cost_per_hour <= 0")
            result = self.cur.fetchone()[0]
            self.assertEqual(result, 0, "Found invalid cost_per_hour values")
    
        def tearDown(self):
            self.cur.close()
            self.conn.close()
    
    if __name__ == "__main__":
        unittest.main()
    
    ```
    
    - Ensures that **negative or zero costs are never stored** in the database.

---

### **4. Data Consistency Checks Across Tables**

**Why?** Ensures cost data is **aligned with resource allocation, billing, and server metrics**.

- **Cost vs. Resource Allocation Validation:**
    
    ```sql
    sql
    CopyEdit
    SELECT c.server_id, c.total_monthly_cost, r.allocated_memory
    FROM cost_data c
    JOIN resource_allocation r ON c.server_id = r.server_id
    WHERE c.total_monthly_cost > 5000 AND r.allocated_memory < 4;
    
    ```
    
    - Identifies **high-cost servers with low memory allocation**, which may indicate **billing discrepancies**.
- **Cost vs. Billing Data Reconciliation:**
    
    ```sql
    sql
    CopyEdit
    SELECT c.server_id, c.total_monthly_cost, b.billed_amount
    FROM cost_data c
    JOIN billing_data b ON c.server_id = b.server_id
    WHERE ABS(c.total_monthly_cost - b.billed_amount) > 50;
    
    ```
    
    - Detects **mismatches between logged costs and actual billing records**.

---

### **5. Data Retention & Cleanup Strategies**

**Why?** Prevents **database bloat** and ensures cost data remains relevant.

- **Only retain the last 2 years of cost data for active analysis:**
    
    ```sql
    sql
    CopyEdit
    DELETE FROM cost_data WHERE timestamp < NOW() - INTERVAL '2 years';
    
    ```
    
    - **Older records** are archived in a separate **historical cost archive**.
- **Scheduled cleanup jobs run periodically to remove unnecessary records:**
    
    ```sql
    sql
    CopyEdit
    CREATE OR REPLACE FUNCTION cleanup_old_cost_data() RETURNS void AS $$
    BEGIN
        DELETE FROM cost_data WHERE timestamp < NOW() - INTERVAL '2 years';
    END;
    $$ LANGUAGE plpgsql;
    
    SELECT cron.schedule('0 3 * * 1', 'SELECT cleanup_old_cost_data();'); -- Runs every Monday at 3 AM
    
    ```
    
    - **Prevents unnecessary data accumulation** and **keeps queries fast**.

---

### **6. Handling Edge Cases & Error Scenarios**

**Why?** Prevents **unexpected failures** and ensures **robust cost tracking**.

- **Handling missing or delayed cost data:**
    - **Scenario:** A server’s cost data is missing for a specific day.
    - **Solution:** **Interpolate missing values** using previous day’s cost.
        
        ```sql
        sql
        CopyEdit
        SELECT server_id, timestamp,
               COALESCE(cost_per_hour, LAG(cost_per_hour) OVER (PARTITION BY server_id ORDER BY timestamp)) AS corrected_cost
        FROM cost_data;
        
        ```
        
    - Ensures **no gaps in financial reporting** due to missing records.
- **Detecting and handling duplicate cost entries:**
    
    ```sql
    sql
    CopyEdit
    DELETE FROM cost_data
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY server_id, timestamp ORDER BY id) AS rownum
            FROM cost_data
        ) t WHERE rownum > 1
    );
    
    ```
    
    - **Prevents duplicate billing** due to **double cost entries**.

---

### **Summary of Validation & Integrity Strategies**

| **Validation Method** | **Purpose** | **Trade-offs** |
| --- | --- | --- |
| **Check Constraints** | Prevent invalid cost values (negative, zero) | Requires predefined rules |
| **Foreign Key Constraints** | Ensure costs reference valid servers | Cascading deletes must be handled carefully |
| **Automated Anomaly Detection** | Identify outliers and billing errors | Thresholds must be tuned to avoid false positives |
| **Unit Tests with pgTAP & Python** | Validate cost calculations | Requires test maintenance |
| **Cross-Table Consistency Checks** | Ensure alignment with billing & resource usage | Additional processing overhead |
| **Retention & Cleanup Policies** | Keep database optimized and relevant | Must balance data availability vs. performance |
| **Error Handling for Missing Data** | Prevent gaps in financial reporting | Requires interpolation logic |

---

### **Next Steps**

Would you like to **extend testing strategies with more automated logging or integrate cost validation with an external financial dashboard (e.g., Tableau, Power BI)?** 🚀