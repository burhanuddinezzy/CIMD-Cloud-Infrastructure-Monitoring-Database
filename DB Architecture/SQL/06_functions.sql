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
