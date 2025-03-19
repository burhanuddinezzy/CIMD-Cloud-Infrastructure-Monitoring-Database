ALTER TABLE server_metrics ADD COLUMN io_wait FLOAT NULL;
ALTER TABLE server_metrics DROP COLUMN error_count;


ALTER TABLE aggregated_metrics ADD COLUMN peak_memory_usage DECIMAL(5,2);


-- 03_alter_tables.sql - Modify Table Structure
ALTER TABLE alert_history ADD COLUMN response_time INTERVAL;
