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
