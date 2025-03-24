ALTER TABLE server_metrics ADD COLUMN io_wait FLOAT NULL;
ALTER TABLE server_metrics DROP COLUMN error_count;


ALTER TABLE aggregated_metrics ADD COLUMN peak_memory_usage DECIMAL(5,2);


-- 03_alter_tables.sql - Modify Table Structure
ALTER TABLE alert_history ADD COLUMN response_time INTERVAL;



-- 03_alter_tables.sql - Modifications (if any)
ALTER TABLE alert_configuration ADD COLUMN notification_channel VARCHAR(50);



-- 03_alter_tables.sql - Modifications (if any)
ALTER TABLE application_logs ADD COLUMN response_time_ms INTEGER;


-- 03_alter_tables.sql - Modifications (if any)
ALTER TABLE cost_data ADD COLUMN additional_notes TEXT;


-- 03_alter_tables.sql - Schema modifications (if needed)
ALTER TABLE downtime_logs ADD COLUMN additional_notes TEXT;
