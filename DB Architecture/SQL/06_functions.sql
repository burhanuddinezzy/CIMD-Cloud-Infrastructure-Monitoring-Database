CREATE OR REPLACE FUNCTION get_avg_cpu_usage(server UUID)
RETURNS FLOAT AS $$
DECLARE avg_cpu FLOAT;
BEGIN
    SELECT AVG(cpu_usage) INTO avg_cpu FROM server_metrics WHERE server_id = server;
    RETURN avg_cpu;
END;
$$ LANGUAGE plpgsql;
