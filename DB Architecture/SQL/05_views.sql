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


