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
