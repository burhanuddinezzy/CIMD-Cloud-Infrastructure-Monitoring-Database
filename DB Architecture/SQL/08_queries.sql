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



-- 08_queries.sql - Common Queries
-- Get all unresolved alerts
SELECT * FROM alert_history WHERE alert_status = 'OPEN';

-- Get alerts for a specific server
SELECT * FROM alert_history WHERE server_id = 'your-server-id';

-- Count alerts by severity
SELECT alert_severity, COUNT(*) FROM alert_history GROUP BY alert_severity;



-- 08_queries.sql - Useful queries
-- Get all active alerts
SELECT * FROM active_alerts;

-- Find alerts by severity level
SELECT * FROM alert_configuration WHERE severity_level = 'CRITICAL';

-- Count of alerts by type
SELECT alert_type, COUNT(*) FROM alert_configuration GROUP BY alert_type;



-- 08_queries.sql - Useful queries
-- Retrieve the last 50 critical logs
SELECT * FROM application_logs
WHERE log_level = 'CRITICAL'
ORDER BY log_timestamp DESC
LIMIT 50;

-- Count logs per application
SELECT app_name, COUNT(*) AS log_count FROM application_logs
GROUP BY app_name
ORDER BY log_count DESC;

-- Find logs from a specific server in the last 24 hours
SELECT * FROM application_logs
WHERE server_id = '550e8400-e29b-41d4-a716-446655440000'
AND log_timestamp > now() - INTERVAL '24 hours'
ORDER BY log_timestamp DESC;



-- 08_queries.sql - Useful queries
-- Query to retrieve the top 5 most expensive servers
SELECT server_id, region, total_monthly_cost 
FROM cost_data 
ORDER BY total_monthly_cost DESC 
LIMIT 5;

-- Query to calculate the average daily cost per team
SELECT team_allocation, AVG(cost_per_day) AS avg_daily_cost
FROM cost_data
GROUP BY team_allocation;

-- 08_queries.sql - Useful queries
-- 1. Retrieve all downtime logs for a specific server
SELECT * FROM downtime_logs WHERE server_id = '550e8400-e29b-41d4-a716-446655440000';

-- 2. Count downtime events per server
SELECT server_id, COUNT(*) AS total_downtime FROM downtime_logs GROUP BY server_id;

-- 3. Get total downtime duration per server
SELECT server_id, SUM(downtime_duration_minutes) AS total_downtime_minutes FROM downtime_logs GROUP BY server_id;

-- 4. Identify the most common downtime causes
SELECT downtime_cause, COUNT(*) AS occurrences FROM downtime_logs GROUP BY downtime_cause ORDER BY occurrences DESC;

-- 5. Find downtime events affecting SLA compliance
SELECT * FROM downtime_logs WHERE sla_tracking = TRUE;
