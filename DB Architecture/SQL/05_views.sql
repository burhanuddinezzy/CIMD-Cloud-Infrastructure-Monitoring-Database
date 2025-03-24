CREATE VIEW recent_server_metrics AS
SELECT server_id, region, timestamp, cpu_usage, memory_usage, disk_usage_percent
FROM server_metrics
WHERE timestamp >= NOW() - INTERVAL '1 day';


CREATE VIEW avg_metrics_per_region AS
SELECT 
    region, 
    AVG(hourly_avg_cpu_usage) AS avg_cpu, 
    AVG(hourly_avg_memory_usage) AS avg_memory, 
    AVG(average_response_time) AS avg_response_time
FROM aggregated_metrics
GROUP BY region;


-- 05_views.sql - Create Views
CREATE VIEW open_alerts AS
SELECT * FROM alert_history WHERE alert_status = 'OPEN';



-- 05_views.sql - Useful views for querying
CREATE VIEW active_alerts AS
SELECT alert_config_id, server_id, metric_name, threshold_value, alert_frequency, contact_email, alert_type, severity_level
FROM alert_configuration WHERE alert_enabled = TRUE;



-- 05_views.sql - Useful views for querying
CREATE VIEW recent_errors AS
SELECT * FROM application_logs
WHERE log_level IN ('ERROR', 'CRITICAL')
ORDER BY log_timestamp DESC
LIMIT 100;



-- 05_views.sql - Useful views for querying
CREATE VIEW cost_summary AS
SELECT region, SUM(total_monthly_cost) AS total_cost
FROM cost_data
GROUP BY region;



-- 05_views.sql - Useful views for querying
CREATE VIEW downtime_summary AS
SELECT server_id, COUNT(*) AS total_downtime_events, SUM(downtime_duration_minutes) AS total_downtime_minutes
FROM downtime_logs
GROUP BY server_id;
