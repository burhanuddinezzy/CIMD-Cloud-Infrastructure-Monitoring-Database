CREATE INDEX idx_server_metrics_region ON server_metrics(region);
CREATE INDEX idx_server_metrics_cpu_usage ON server_metrics(cpu_usage);
CREATE INDEX idx_server_metrics_memory_usage ON server_metrics(memory_usage);


CREATE INDEX idx_aggregated_metrics_region ON aggregated_metrics(region);
CREATE INDEX idx_aggregated_metrics_timestamp ON aggregated_metrics(timestamp);


-- 04_indexes.sql - Performance Optimization
CREATE INDEX idx_alert_history_server ON alert_history(server_id); 
CREATE INDEX idx_alert_history_status ON alert_history(alert_status);
CREATE INDEX idx_alert_history_severity ON alert_history(alert_severity);


-- 04_indexes.sql - Indexes for performance
CREATE INDEX idx_alert_config_server ON alert_configuration(server_id);
CREATE INDEX idx_alert_config_metric ON alert_configuration(metric_name);


-- 04_indexes.sql - Indexes for performance
CREATE INDEX idx_application_logs_server ON application_logs(server_id);
CREATE INDEX idx_application_logs_timestamp ON application_logs(log_timestamp DESC);
CREATE INDEX idx_application_logs_log_level ON application_logs(log_level);



-- 04_indexes.sql - Indexes for performance
CREATE INDEX idx_cost_data_server ON cost_data (server_id);
CREATE INDEX idx_cost_data_timestamp ON cost_data (timestamp);



-- 04_indexes.sql - Indexes for performance optimization
CREATE INDEX idx_downtime_server ON downtime_logs(server_id);
CREATE INDEX idx_downtime_start_time ON downtime_logs(start_time);
CREATE INDEX idx_downtime_incident ON downtime_logs(incident_id);


-- Index for faster searches by server_id
CREATE INDEX idx_error_logs_server_id ON error_logs (server_id);

-- Index for quickly finding unresolved critical errors
CREATE INDEX idx_unresolved_critical_errors ON error_logs (error_severity, resolved) WHERE resolved = FALSE AND error_severity = 'CRITICAL';

-- Index for efficient timestamp-based searches
CREATE INDEX idx_error_logs_timestamp ON error_logs (timestamp DESC);


-- Index for quick lookups by status
CREATE INDEX idx_incident_status ON incident_response_logs (status);

-- Index for faster retrieval of unresolved incidents
CREATE INDEX idx_open_incidents ON incident_response_logs (status) WHERE status != 'Resolved';

-- Index for performance optimization on priority level filtering
CREATE INDEX idx_priority_level ON incident_response_logs (priority_level);



-- Index on frequently searched fields
CREATE INDEX idx_resource_allocation_server ON resource_allocation (server_id);
CREATE INDEX idx_resource_allocation_app ON resource_allocation (app_id);
CREATE INDEX idx_resource_allocation_status ON resource_allocation (allocation_status);
CREATE INDEX idx_resource_allocation_utilization ON resource_allocation (utilization_percentage);



CREATE INDEX idx_team_name ON team_management (team_name);
CREATE INDEX idx_team_status ON team_management (status);
CREATE INDEX idx_team_member_email ON team_members (email);
