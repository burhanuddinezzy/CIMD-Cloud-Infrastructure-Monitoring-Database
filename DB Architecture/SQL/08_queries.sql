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



-- Get servers with an error rate above 2%
SELECT server_id, error_rate 
FROM aggregated_metrics 
WHERE error_rate > 2.00;

-- Get the top 5 regions with the highest average response time
SELECT region, AVG(average_response_time) AS avg_response_time
FROM aggregated_metrics
GROUP BY region
ORDER BY avg_response_time DESC
LIMIT 5;

-- Get the total number of requests processed per region
SELECT region, SUM(total_requests) AS total_requests
FROM aggregated_metrics
GROUP BY region;

