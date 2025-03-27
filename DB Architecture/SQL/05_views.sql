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



-- View showing unresolved errors with detailed information
CREATE VIEW view_unresolved_errors AS
SELECT 
    error_id, server_id, timestamp, error_severity, error_message, error_source
FROM error_logs
WHERE resolved = FALSE;

-- View showing error resolution statistics
CREATE VIEW view_error_resolution_stats AS
SELECT 
    error_severity,
    COUNT(*) AS total_errors,
    COUNT(CASE WHEN resolved THEN 1 END) AS resolved_errors,
    COUNT(CASE WHEN NOT resolved THEN 1 END) AS unresolved_errors
FROM error_logs
GROUP BY error_severity;


-- View showing all unresolved incidents
CREATE VIEW view_unresolved_incidents AS
SELECT 
    incident_id, server_id, timestamp, response_team_id, incident_summary, status, priority_level, escalation_flag
FROM incident_response_logs
WHERE status NOT IN ('Resolved');

-- View displaying the average resolution time per priority level
CREATE VIEW view_avg_resolution_time AS
SELECT 
    priority_level, 
    AVG(resolution_time_minutes) AS avg_resolution_time
FROM incident_response_logs
WHERE resolution_time_minutes IS NOT NULL
GROUP BY priority_level;


-- View to monitor high utilization resources
CREATE VIEW high_utilization_resources AS
SELECT 
    server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
    utilization_percentage, autoscaling_enabled, allocation_status
FROM resource_allocation
WHERE utilization_percentage > 80;

-- View to estimate total cost per server
CREATE VIEW server_resource_cost AS
SELECT 
    server_id, SUM(cost_per_hour) AS total_hourly_cost
FROM resource_allocation
GROUP BY server_id;


CREATE VIEW active_teams AS
SELECT team_id, team_name, status, location FROM team_management
WHERE status = 'Active';

CREATE VIEW team_members_view AS
SELECT tm.team_name, m.member_id, m.role, m.email, m.date_joined
FROM team_members m
JOIN team_management tm ON m.team_id = tm.team_id;


