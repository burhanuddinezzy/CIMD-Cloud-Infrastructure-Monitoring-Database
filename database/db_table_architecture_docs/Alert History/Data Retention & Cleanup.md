# Data Retention & Cleanup

- **Keep only 6 months of active alerts; archive older ones.**
    - **Why?** Keeping all alerts indefinitely can slow queries and increase storage costs.
    - **How?**
        - Implement **partitioning** so older data can be removed efficiently.
        - Archive alerts in a **separate table** (`alert_history_archive`) or move them to **cold storage** like Oracle Cloud Object Storage, AWS S3, or Azure Blob Storage.
        - Use **table inheritance** in PostgreSQL to separate active and archived alerts while keeping queries seamless.
    - **Example (Partitioning by Date):**
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE alert_history (
            alert_id UUID PRIMARY KEY,
            server_id UUID,
            alert_type VARCHAR(50),
            threshold_value DECIMAL(10,2),
            alert_triggered_at TIMESTAMP,
            resolved_at TIMESTAMP NULL,
            alert_status ENUM('OPEN', 'CLOSED')
        ) PARTITION BY RANGE (alert_triggered_at);
        
        CREATE TABLE alert_history_active PARTITION OF alert_history
        FOR VALUES FROM ('2024-08-01') TO ('2025-02-01');
        
        CREATE TABLE alert_history_archive PARTITION OF alert_history
        FOR VALUES FROM ('2023-02-01') TO ('2024-08-01') TABLESPACE cold_storage;
        
        ```
        
        - Allows efficient **data aging** without impacting query performance.
- **Run nightly jobs to delete outdated non-critical alerts.**
    - **Why?** Not all alerts need long-term storage, especially **low-severity** ones.
    - **How?**
        - Use **cron jobs** or **PostgreSQL pgAgent** to delete non-critical alerts every night.
        - Set up a **DELETE policy** for alerts older than 3 months, but **only if they were resolved**.
    - **Example (Scheduled Cleanup Job):**
        
        ```sql
        sql
        CopyEdit
        CREATE OR REPLACE FUNCTION cleanup_old_alerts()
        RETURNS void AS $$
        BEGIN
            DELETE FROM alert_history
            WHERE alert_status = 'CLOSED'
            AND alert_triggered_at < NOW() - INTERVAL '3 months';
        END;
        $$ LANGUAGE plpgsql;
        
        SELECT cron.schedule('daily_cleanup', '0 2 * * *', $$CALL cleanup_old_alerts()$$);
        
        ```
        
        - Ensures **non-critical alerts don’t clutter the database**, improving query speeds.
- **Tiered Storage for Different Alert Severities.**
    - **Why?** Critical alerts should be stored longer than minor ones.
    - **How?**
        - Store **critical alerts** (`disk failure`, `CPU overload`) for **1 year**.
        - Store **medium-severity alerts** (`high memory usage`, `slow response time`) for **6 months**.
        - Store **low-severity alerts** (`temporary CPU spike`, `small network delay`) for **3 months**.
    - **Example (Table Partitioning by Severity & Date):**
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE alert_history_critical PARTITION OF alert_history
        FOR VALUES FROM ('2024-02-01') TO ('2025-02-01');
        
        CREATE TABLE alert_history_medium PARTITION OF alert_history
        FOR VALUES FROM ('2024-02-01') TO ('2024-08-01');
        
        CREATE TABLE alert_history_low PARTITION OF alert_history
        FOR VALUES FROM ('2024-02-01') TO ('2024-05-01');
        
        ```
        
        - **Improves data retrieval speed** while keeping important alerts accessible.
- **Soft Deletes Instead of Immediate Deletion.**
    - **Why?** In case of accidental deletions, a **soft delete** allows temporary recovery.
    - **How?**
        - Add a **boolean column (`is_deleted`)** to mark alerts as deleted instead of removing them immediately.
        - Periodically **purge** soft-deleted records from storage.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        ALTER TABLE alert_history ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
        
        UPDATE alert_history SET is_deleted = TRUE
        WHERE alert_status = 'CLOSED'
        AND alert_triggered_at < NOW() - INTERVAL '3 months';
        
        ```
        
        - Allows **undo operations** before permanent deletion.
- **Index Maintenance & Vacuuming to Prevent Table Bloat.**
    - **Why?** Regular deletions create dead tuples, slowing down queries.
    - **How?**
        - Schedule **VACUUM ANALYZE** to reclaim storage and optimize indexes.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        VACUUM ANALYZE alert_history;
        
        ```
        
        - Keeps the table **lightweight and fast**.