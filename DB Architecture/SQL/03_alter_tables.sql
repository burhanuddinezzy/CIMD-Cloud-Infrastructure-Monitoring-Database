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


-- Add an index for faster filtering by timestamp
ALTER TABLE error_logs ADD COLUMN created_at TIMESTAMP DEFAULT NOW();

-- Add a new severity level if needed
ALTER TABLE error_logs DROP CONSTRAINT error_logs_error_severity_check;
ALTER TABLE error_logs ADD CONSTRAINT error_logs_error_severity_check CHECK (error_severity IN ('INFO', 'WARNING', 'CRITICAL', 'FATAL'));



-- Add a column for tracking incident resolution timestamps
ALTER TABLE incident_response_logs ADD COLUMN resolved_at TIMESTAMP NULL;

-- Modify escalation_flag to default to NULL instead of FALSE for better tracking
ALTER TABLE incident_response_logs ALTER COLUMN escalation_flag DROP DEFAULT;




-- Add a new column to track the last modified timestamp
ALTER TABLE resource_allocation ADD COLUMN last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Modify cost_per_hour to allow higher precision
ALTER TABLE resource_allocation ALTER COLUMN cost_per_hour TYPE DECIMAL(12,6);



ALTER TABLE team_management ADD COLUMN budget DECIMAL(10,2);
ALTER TABLE team_members ADD COLUMN phone_number VARCHAR(20);



-- Add an optional field for geolocation tracking
ALTER TABLE user_access_logs ADD COLUMN geo_location VARCHAR(100);

