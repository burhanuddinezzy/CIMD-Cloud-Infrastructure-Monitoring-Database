CREATE OR REPLACE FUNCTION get_avg_cpu_usage(server UUID)
RETURNS FLOAT AS $$
DECLARE avg_cpu FLOAT;
BEGIN
    SELECT AVG(cpu_usage) INTO avg_cpu FROM server_metrics WHERE server_id = server;
    RETURN avg_cpu;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_high_error_servers(threshold DECIMAL(5,2)) 
RETURNS TABLE(server_id UUID, error_rate DECIMAL(5,2)) AS $$
BEGIN
    RETURN QUERY 
    SELECT server_id, error_rate 
    FROM aggregated_metrics 
    WHERE error_rate > threshold;
END;
$$ LANGUAGE plpgsql;



-- 06_functions.sql - Stored Procedures
CREATE OR REPLACE FUNCTION get_high_severity_alerts()
RETURNS TABLE(alert_id UUID, alert_type VARCHAR, alert_severity VARCHAR) AS $$
BEGIN
    RETURN QUERY 
    SELECT alert_id, alert_type, alert_severity FROM alert_history WHERE alert_severity = 'CRITICAL';
END;
$$ LANGUAGE plpgsql;


-- 06_functions.sql - Stored procedures for automation
CREATE OR REPLACE FUNCTION disable_alert(alert_id UUID) RETURNS VOID AS $$
BEGIN
    UPDATE alert_configuration SET alert_enabled = FALSE WHERE alert_config_id = alert_id;
END;
$$ LANGUAGE plpgsql;



-- 06_functions.sql - Stored procedures
CREATE FUNCTION insert_application_log(
    p_server_id UUID, p_app_name VARCHAR, p_log_level application_logs.log_level%TYPE,
    p_error_code VARCHAR, p_trace_id UUID, p_span_id UUID, p_source_ip INET,
    p_user_id UUID, p_log_source application_logs.log_source%TYPE
) RETURNS VOID AS $$
BEGIN
    INSERT INTO application_logs (server_id, app_name, log_level, error_code, trace_id, span_id, source_ip, user_id, log_source)
    VALUES (p_server_id, p_app_name, p_log_level, p_error_code, p_trace_id, p_span_id, p_source_ip, p_user_id, p_log_source);
END;
$$ LANGUAGE plpgsql;



-- 06_functions.sql - Stored procedures
CREATE OR REPLACE FUNCTION calculate_annual_cost(server UUID) RETURNS DECIMAL(10,2) AS $$
BEGIN
    RETURN (SELECT SUM(total_monthly_cost) * 12 FROM cost_data WHERE server_id = server);
END;
$$ LANGUAGE plpgsql;



-- 06_functions.sql - Stored procedures
CREATE FUNCTION get_downtime_for_server(p_server_id UUID) RETURNS TABLE (
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    downtime_cause VARCHAR(255),
    downtime_duration_minutes INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT start_time, end_time, downtime_cause, downtime_duration_minutes 
    FROM downtime_logs WHERE server_id = p_server_id;
END;
$$ LANGUAGE plpgsql;



-- Function to automatically resolve an error and log resolution time
CREATE OR REPLACE FUNCTION resolve_error(error_id_param UUID, resolution_action VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE error_logs
    SET resolved = TRUE, resolved_at = NOW(), recovery_action = resolution_action
    WHERE error_id = error_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to count unresolved errors by severity
CREATE OR REPLACE FUNCTION count_unresolved_errors(severity TEXT)
RETURNS INT AS $$
DECLARE
    error_count INT;
BEGIN
    SELECT COUNT(*) INTO error_count FROM error_logs WHERE error_severity = severity AND resolved = FALSE;
    RETURN error_count;
END;
$$ LANGUAGE plpgsql;


-- Function to update an incident status
CREATE OR REPLACE FUNCTION update_incident_status(incident_id_param UUID, new_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE incident_response_logs
    SET status = new_status
    WHERE incident_id = incident_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate the average resolution time of resolved incidents
CREATE OR REPLACE FUNCTION get_avg_resolution_time()
RETURNS NUMERIC AS $$
DECLARE
    avg_time NUMERIC;
BEGIN
    SELECT AVG(resolution_time_minutes) INTO avg_time FROM incident_response_logs WHERE status = 'Resolved';
    RETURN avg_time;
END;
$$ LANGUAGE plpgsql;


-- Function to calculate average resource utilization per application
CREATE FUNCTION get_avg_utilization(app UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE avg_util DECIMAL(5,2);
BEGIN
    SELECT AVG(utilization_percentage) INTO avg_util
    FROM resource_allocation
    WHERE app_id = app;
    RETURN avg_util;
END;
$$ LANGUAGE plpgsql;

-- Function to deactivate resource allocations for a specific server
CREATE PROCEDURE deactivate_server_allocations(server UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE resource_allocation 
    SET allocation_status = 'deallocated' 
    WHERE server_id = server;
END;
$$;


CREATE OR REPLACE FUNCTION get_team_member_count(team_uuid UUID) RETURNS INT AS $$
DECLARE count_members INT;
BEGIN
    SELECT COUNT(*) INTO count_members FROM team_members WHERE team_id = team_uuid;
    RETURN count_members;
END;
$$ LANGUAGE plpgsql;

