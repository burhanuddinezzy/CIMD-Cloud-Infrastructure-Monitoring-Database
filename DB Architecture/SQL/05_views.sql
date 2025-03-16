CREATE VIEW recent_server_metrics AS
SELECT server_id, region, timestamp, cpu_usage, memory_usage, disk_usage_percent
FROM server_metrics
WHERE timestamp >= NOW() - INTERVAL '1 day';
