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



-- Get all critical unresolved errors
SELECT * FROM error_logs WHERE error_severity = 'CRITICAL' AND resolved = FALSE;

-- Get all errors that occurred in the last 24 hours
SELECT * FROM error_logs WHERE timestamp >= NOW() - INTERVAL '1 day';

-- Count total errors grouped by severity
SELECT error_severity, COUNT(*) AS total_errors FROM error_logs GROUP BY error_severity;

-- Find errors linked to incidents
SELECT e.*, i.incident_description
FROM error_logs e
JOIN incident_management i ON e.incident_id = i.incident_id;

-- Get the average resolution time of resolved errors
SELECT AVG(EXTRACT(EPOCH FROM (resolved_at - timestamp)) / 60) AS avg_resolution_time_minutes
FROM error_logs
WHERE resolved = TRUE;




-- Get all unresolved high-priority incidents
SELECT * FROM incident_response_logs WHERE status NOT IN ('Resolved') AND priority_level IN ('High', 'Critical');

-- Get the most recent incidents
SELECT * FROM incident_response_logs ORDER BY timestamp DESC LIMIT 10;

-- Count incidents by status
SELECT status, COUNT(*) AS count FROM incident_response_logs GROUP BY status;

-- Find incidents that required escalation
SELECT * FROM incident_response_logs WHERE escalation_flag = TRUE;

-- Get the team responsible for resolving the most incidents
SELECT response_team_id, COUNT(*) AS resolved_incidents
FROM incident_response_logs
WHERE status = 'Resolved'
GROUP BY response_team_id
ORDER BY resolved_incidents DESC LIMIT 1;


-- Find all active resource allocations
SELECT * FROM resource_allocation WHERE allocation_status = 'active';

-- Get the highest utilization percentage for each workload type
SELECT workload_type, MAX(utilization_percentage) AS max_util
FROM resource_allocation
GROUP BY workload_type;

-- Identify applications with over-allocated resources (where actual usage is significantly lower)
SELECT app_id, allocated_memory, actual_memory_usage, allocated_cpu, actual_cpu_usage
FROM resource_allocation
WHERE actual_memory_usage < (allocated_memory * 0.5)
   OR actual_cpu_usage < (allocated_cpu * 0.5);

-- Calculate the total hourly cost per server
SELECT server_id, SUM(cost_per_hour) AS total_cost_per_hour
FROM resource_allocation
GROUP BY server_id;


-- Get all active teams
SELECT * FROM team_management WHERE status = 'Active';

-- Get team members for a specific team
SELECT m.member_id, m.role, m.email
FROM team_members m
JOIN team_management tm ON m.team_id = tm.team_id
WHERE tm.team_name = 'DevOps';

-- Get team assignments for a given server
SELECT tm.team_name
FROM team_server_assignment tsa
JOIN team_management tm ON tsa.team_id = tm.team_id
WHERE tsa.server_id = '123e4567-e89b-12d3-a456-426614174000';


-- Get all access logs for a specific user
SELECT * FROM user_access_logs WHERE user_id = '550e8400-e29b-41d4-a716-446655440000';

-- Get all access logs for a specific server
SELECT * FROM user_access_logs WHERE server_id = '660e8400-e29b-41d4-a716-446655440001';

-- Find all accesses from a specific IP address
SELECT * FROM user_access_logs WHERE access_ip = '203.0.113.42';

-- Get the most recent access for each user
SELECT DISTINCT ON (user_id) user_id, access_id, access_type, timestamp, access_ip, user_agent
FROM user_access_logs
ORDER BY user_id, timestamp DESC;

