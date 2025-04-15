# Data Retention & Cleanup

Efficient data retention ensures that cost data remains useful without overwhelming the database. Cost tracking typically requires recent data for budgeting, while older records are referenced less frequently. This section expands on **how to retain critical data, archive historical records, and automate cleanup.**

### **1. Retention Policy for Cost Data**

- **Why?** Keeping all cost data indefinitely results in **slow queries, increased storage costs, and bloated indexes**.
- **How?** Implement **tiered retention**:
    - **Retain the last 2 years of data** in the main table for active reporting.
    - **Move older records to an archive table** for historical analysis.
    - **Delete records older than 5 years** if no compliance requirements mandate keeping them.
- **Example Policy:**
    - **0–24 months:** Keep in `cost_data` (frequent access).
    - **2–5 years:** Move to `cost_data_archive` (rare access, used for audits).
    - **5+ years:** Delete unless required for compliance.

### **2. Archiving Historical Cost Data**

- **Why?** Moving old data to an archive table improves query performance on frequently accessed records.
- **How?**
    - Create an **archive table** for old cost records:
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE cost_data_archive (
            server_id UUID,
            region VARCHAR(20),
            timestamp TIMESTAMP,
            cost_per_hour DECIMAL(10,2),
            total_monthly_cost DECIMAL(10,2),
            team_allocation VARCHAR(50)
        ) PARTITION BY RANGE (timestamp);
        
        ```
        
    - Schedule a **monthly migration job** to move old data:
        
        ```sql
        sql
        CopyEdit
        INSERT INTO cost_data_archive
        SELECT * FROM cost_data WHERE timestamp < NOW() - INTERVAL '2 years';
        
        DELETE FROM cost_data WHERE timestamp < NOW() - INTERVAL '2 years';
        
        ```
        
    - Store **compressed historical records** in a **data warehouse** like BigQuery or Amazon S3 for long-term storage.

### **3. Automating Data Cleanup**

- **Why?** Manually removing old data is error-prone and inefficient. **Automated cleanup scripts** ensure consistent data management.
- **How?** Use a **cron job** or **database job scheduler** to periodically purge old records.
    - **PostgreSQL's `pg_cron`** can automate deletion:
        
        ```sql
        sql
        CopyEdit
        SELECT cron.schedule('0 2 * * 1', -- Runs every Monday at 2 AM
            'DELETE FROM cost_data WHERE timestamp < NOW() - INTERVAL ''5 years''');
        
        ```
        
    - **Alternative:** Use a background worker in Node.js/Python to run deletion queries on schedule.

### **4. Storing Archived Data in a Cost-Optimized Format**

- **Why?** Traditional relational databases are costly for storing rarely accessed data.
- **How?** Move archived records to **cost-efficient storage**:
    - Store **compressed Parquet files** in **Amazon S3 or Google Cloud Storage**.
    - Use **Amazon Athena or Google BigQuery** to query archived data when needed.
    - Example: Export old cost records to Parquet before deleting them:
        
        ```bash
        bash
        CopyEdit
        psql -d mydb -c "COPY (SELECT * FROM cost_data_archive) TO '/tmp/cost_data_2020.parquet' FORMAT 'parquet';"
        aws s3 cp /tmp/cost_data_2020.parquet s3://my-cost-archive/
        
        ```
        
    - **Performance Gains:**
        - Saves on **expensive database storage**.
        - **Faster queries** for active data, since old records are not scanned.
    - **Trade-off:** Requires **separate tools (Athena, BigQuery) to access archived records.**

### **5. Handling Compliance & Legal Requirements**

- **Why?** Some industries (e.g., finance, healthcare) have legal mandates on data retention.
- **How?**
    - Define retention policies based on compliance needs (e.g., **HIPAA, GDPR, SOX**).
    - Store **audit logs** of deleted records to prove compliance.
    - Example: Store a **log of deleted cost records**:
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE cost_data_deletion_log (
            server_id UUID,
            region VARCHAR(20),
            timestamp TIMESTAMP,
            deleted_at TIMESTAMP DEFAULT NOW(),
            deleted_by VARCHAR(50)
        );
        
        INSERT INTO cost_data_deletion_log (server_id, region, timestamp)
        SELECT server_id, region, timestamp FROM cost_data WHERE timestamp < NOW() - INTERVAL '5 years';
        
        DELETE FROM cost_data WHERE timestamp < NOW() - INTERVAL '5 years';
        
        ```
        
    - **Performance Gains:**
        - Ensures **compliance with data laws**.
        - Logs provide **traceability for audits**.
    - **Trade-off:** Slight increase in storage due to **deletion logging**.

---

### **Summary of Data Retention & Cleanup Strategies**

| **Strategy** | **Benefit** | **Trade-offs** |
| --- | --- | --- |
| **Retention Policy (2-5 years)** | Keeps recent data while preventing bloat | Requires defining business retention rules |
| **Archiving to Separate Table** | Improves query speed on active data | Archived data requires separate queries |
| **Automated Cleanup Jobs** | Ensures consistent data removal | Risk of accidental deletions if misconfigured |
| **Storing Archived Data in S3** | Reduces database storage costs | Needs separate tools (Athena, BigQuery) for access |
| **Audit Logs for Compliance** | Ensures legal retention requirements are met | Adds minor storage overhead |