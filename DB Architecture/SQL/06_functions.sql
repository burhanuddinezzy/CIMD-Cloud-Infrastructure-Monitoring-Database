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
