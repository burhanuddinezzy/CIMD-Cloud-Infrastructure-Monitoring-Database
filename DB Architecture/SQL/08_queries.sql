-- Get servers with high CPU usage (> 85%)
SELECT server_id, region, timestamp, cpu_usage
FROM server_metrics
WHERE cpu_usage > 85
ORDER BY timestamp DESC;

-- Get the average latency per region
SELECT region, AVG(latency_in_ms) AS avg_latency
FROM server_metrics
GROUP BY region;

-- Find servers with the highest disk read throughput
SELECT server_id, region, disk_read_throughput
FROM server_metrics
ORDER BY disk_read_throughput DESC
LIMIT 5;
