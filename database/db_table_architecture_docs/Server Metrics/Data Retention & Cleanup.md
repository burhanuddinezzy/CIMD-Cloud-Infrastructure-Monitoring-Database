# Data Retention & Cleanup

### **1. Define a Retention Policy for Different Data Types**

- Not all data needs to be kept live indefinitely. Define **different retention periods** based on data importance.
- **Example Retention Strategy:**
    - **Real-time monitoring metrics**: Retain for **1 year**, archive older data.
    - **Error logs**: Keep for **6 months**, then move to cold storage.
    - **User access logs**: Retain for **1 year**, then delete for compliance.
    - **Aggregated historical metrics**: Keep **indefinitely** for trend analysis.

### **2. Automatically Archive Older Data**

- Moving old data to **cold storage** reduces database bloat and speeds up queries.
- **Example: Automatically Archive Data Older Than 1 Year**
    
    ```sql
    sql
    CopyEdit
    INSERT INTO server_metrics_archive
    SELECT * FROM server_metrics WHERE timestamp < NOW() - INTERVAL '1 year';
    DELETE FROM server_metrics WHERE timestamp < NOW() - INTERVAL '1 year';
    
    ```
    
- **Automate using a scheduled PostgreSQL job:**
    
    ```sql
    sql
    CopyEdit
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    SELECT cron.schedule('0 3 * * 1', 'INSERT INTO server_metrics_archive SELECT * FROM server_metrics WHERE timestamp < NOW() - INTERVAL ''1 year''; DELETE FROM server_metrics WHERE timestamp < NOW() - INTERVAL ''1 year'';');
    
    ```
    
    - This runs **every Monday at 3 AM** to archive & delete old records.
    - Store archived data in **AWS S3, BigQuery, or an analytics database**.

### **3. Use Table Partitioning for Efficient Cleanup**

- Instead of deleting individual rows (which is slow), **drop entire partitions**.
- **Example: Partitioning by Month**
    
    ```sql
    sql
    CopyEdit
    CREATE TABLE server_metrics_y2025m01 PARTITION OF server_metrics
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
    
    ```
    
- **Drop old partitions instead of running `DELETE` queries:**
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics DETACH PARTITION server_metrics_y2024m01;
    DROP TABLE server_metrics_y2024m01;
    
    ```
    
    - This is **faster and avoids table fragmentation**.

### **4. Use VACUUM & ANALYZE to Prevent Database Bloat**

- Deleting rows in PostgreSQL leaves behind empty space, causing **table bloat**.
- **Regularly run `VACUUM` to reclaim space and optimize indexes:**
    
    ```sql
    sql
    CopyEdit
    VACUUM FULL server_metrics;
    ANALYZE server_metrics;
    
    ```
    
- **Enable autovacuum tuning for better performance:**
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics SET (autovacuum_vacuum_scale_factor = 0.1, autovacuum_analyze_scale_factor = 0.05);
    
    ```
    

### **5. Set Up Automatic Data Expiration with PostgreSQL Policies**

- **PostgreSQL’s `pg_partman` extension** allows automatic partition management.
- **Example: Automatically Drop Old Partitions**
    
    ```sql
    sql
    CopyEdit
    SELECT run_maintenance();
    
    ```
    
    - Automatically removes partitions older than **12 months**.

### **6. Implement Tiered Storage for Cost Efficiency**

- Use a **multi-tier approach** for storing metrics:
    - **Hot Storage (Live DB)**: Last **6-12 months**, frequently accessed data.
    - **Warm Storage (Data Warehouse, S3, BigQuery)**: Last **1-3 years**, historical queries.
    - **Cold Storage (Glacier, Deep Archive)**: Long-term storage for compliance.

### **7. Log Cleanup for Compliance & Security**

- **Error logs, user access logs, and security logs** need controlled retention.
- **GDPR & SOC2 Compliance:**
    - Automatically **anonymize or delete user logs** older than retention limits.
    - Example:
        
        ```sql
        sql
        CopyEdit
        DELETE FROM user_access_logs WHERE timestamp < NOW() - INTERVAL '1 year';
        
        ```
        
    - Encrypt sensitive logs before archiving.

### **8. Monitor Storage Growth & Automate Cleanup**

- Use **pg_stat_all_tables** to track table sizes.
    
    ```sql
    sql
    CopyEdit
    SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_stat_all_tables WHERE schemaname = 'public';
    
    ```
    
- Set up alerts when **table size exceeds a threshold** (e.g., 500GB).

### **Final Takeaways**

- **Define a data retention policy** to balance performance & storage costs.
- **Archive older data automatically** instead of keeping everything live.
- **Use partitioning to speed up deletion and avoid table bloat.**
- **Regularly vacuum & analyze tables** to maintain database health.
- **Ensure compliance with log retention policies (GDPR, SOC2, HIPAA).**

Need help **automating cleanup scripts** or **choosing a storage strategy**? 🚀