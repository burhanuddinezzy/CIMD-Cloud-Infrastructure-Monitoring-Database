INSERT INTO server_metrics (
    server_id, region, timestamp, cpu_usage, memory_usage, disk_read_ops_per_sec, 
    disk_write_ops_per_sec, network_in_bytes, network_out_bytes, uptime_in_mins, 
    latency_in_ms, db_queries_per_sec, disk_usage_percent, error_count, 
    disk_read_throughput, disk_write_throughput
) VALUES 
(
    '550e8400-e29b-41d4-a716-446655440000', 'us-east-1', '2025-03-16 12:00:00',
    45.6, 67.3, 150, 120, 5000000, 3200000, 43560, 12.5, 280, 72.4, 2, 1048576, 2048576
),
(
    '550e8400-e29b-41d4-a716-446655440001', 'eu-west-2', '2025-03-16 12:05:00',
    35.2, 55.8, 130, 140, 4200000, 3100000, 87000, 10.2, 320, 60.7, NULL, 984576, 1784576
);

INSERT INTO aggregated_metrics (
    server_id, region, timestamp, hourly_avg_cpu_usage, 
    hourly_avg_memory_usage, peak_network_usage, peak_disk_usage, 
    uptime_percentage, total_requests, error_rate, average_response_time
) VALUES 
(
    gen_random_uuid(), 'us-east-1', NOW(), 45.75, 70.20, 
    1048576000, 524288000, 99.95, 150000, 0.15, 200.50
);


-- 02_insert_data.sql - Sample Data
INSERT INTO alert_history (
    server_id, alert_type, threshold_value, alert_status, alert_severity, 
    alert_description, resolved_by, alert_source, impact
) VALUES 
(
    gen_random_uuid(), 'CPU Overload', 95.75, 'OPEN', 'HIGH',
    'CPU usage exceeded 95% for 5 minutes.', NULL, 'Monitoring System', 'Performance Degradation'
);




-- 02_insert_data.sql - Provides sample data
INSERT INTO alert_configuration (server_id, metric_name, threshold_value, alert_frequency, contact_email, alert_enabled, alert_type, severity_level)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'CPU Usage', 85.5, '5 minutes', 'admin@example.com', TRUE, 'EMAIL', 'HIGH'),
    ('550e8400-e29b-41d4-a716-446655440001', 'Memory Usage', 90.0, '10 minutes', 'ops@example.com', TRUE, 'WEBHOOK', 'CRITICAL'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Disk Space', 80.0, '30 minutes', 'support@example.com', FALSE, 'SMS', 'MEDIUM');




-- 02_insert_data.sql - Provides sample data
INSERT INTO application_logs (server_id, app_name, log_level, error_code, trace_id, span_id, source_ip, user_id, log_source)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'Billing Service', 'ERROR', 'HTTP 500', '123e4567-e89b-12d3-a456-426614174000', '456e7890-e89b-12d3-a456-426614174001', '192.168.1.100', '660e8400-e29b-41d4-a716-446655440001', 'APP'),
    ('660e8400-e29b-41d4-a716-446655440002', 'Auth Service', 'CRITICAL', 'DB 23505', NULL, NULL, '10.0.0.5', NULL, 'DATABASE');




-- 02_insert_data.sql - Provides sample data
INSERT INTO cost_data (server_id, region, timestamp, cost_per_hour, total_monthly_cost, team_allocation, cost_per_day, cost_type, cost_adjustment, cost_adjustment_reason, cost_basis) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'us-east-1', '2025-03-16 12:00:00', 0.50, 360.00, 'DevOps', 12.00, 'Infrastructure', -10.00, 'Promotional Discount', 'Usage-Based'),
('660e8400-e29b-41d4-a716-446655440111', 'eu-west-1', '2025-03-16 12:00:00', 0.75, 540.00, 'Security', 18.00, 'Cloud Services', 0.00, '', 'Flat-Rate');


-- 02_insert_data.sql - Sample data
INSERT INTO downtime_logs (server_id, start_time, end_time, downtime_cause, sla_tracking, incident_id, is_planned, recovery_action)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', '2025-03-15 12:30:00', '2025-03-15 13:15:00', 'Hardware failure', TRUE, NULL, FALSE, 'Replaced faulty power unit'),
    ('550e8400-e29b-41d4-a716-446655440001', '2025-03-14 22:00:00', NULL, 'Network outage', TRUE, '550e8400-e29b-41d4-a716-446655440002', FALSE, 'ISP notified');


INSERT INTO error_logs (server_id, timestamp, error_severity, error_message, resolved, resolved_at, incident_id, error_source, error_code, recovery_action)
VALUES
    ('a1b2c3-d4e5f6-g7h8i9', '2024-01-30 12:45:00', 'CRITICAL', 'Database connection timeout', FALSE, NULL, NULL, 'Database', NULL, NULL),
    ('d4e5f6-g7h8i9-a1b2c3', '2024-01-30 13:10:00', 'WARNING', 'Disk usage at 85%', TRUE, '2024-01-30 14:00:00', NULL, 'Storage', NULL, 'Cleared unnecessary files'),
    ('b1c2d3-e4f5g6-h7i8j9', '2024-01-31 09:20:00', 'INFO', 'Successful backup completed', TRUE, '2024-01-31 09:25:00', NULL, 'Backup System', NULL, NULL);




INSERT INTO incident_response_logs (server_id, timestamp, response_team_id, incident_summary, resolution_time_minutes, status, priority_level, incident_type, root_cause, escalation_flag, audit_log_id)
VALUES
    ('a1b2c3-d4e5f6-g7h8i9', '2024-02-01 10:30:00', 'team-1234', 'Network outage due to ISP failure', 90, 'Resolved', 'High', 'Network Failure', 'ISP service disruption', FALSE, 'audit-5678'),
    ('d4e5f6-g7h8i9-a1b2c3', '2024-02-02 14:15:00', 'team-5678', 'Unauthorized access attempt detected', NULL, 'Escalated', 'Critical', 'Security Breach', NULL, TRUE, 'audit-7890'),
    ('b1c2d3-e4f5g6-h7i8j9', '2024-02-03 08:00:00', 'team-3456', 'Server overload causing slow response times', 45, 'Resolved', 'Medium', 'Performance Issue', 'High CPU usage due to unoptimized queries', FALSE, NULL);



INSERT INTO resource_allocation (
    server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
    resource_tag, utilization_percentage, autoscaling_enabled, max_allocated_memory,
    max_allocated_cpu, max_allocated_disk_space, actual_memory_usage, actual_cpu_usage,
    actual_disk_usage, cost_per_hour, allocation_status
) VALUES 
(
    '550e8400-e29b-41d4-a716-446655440000', 'aa0e8400-e29b-41d4-a716-446655440001', 'Web Server',
    4096, 2.50, 100, 'Project Alpha', 75.3, TRUE, 8192, 3.50, 200, 3072, 1.75, 80, 0.0456, 'active'
),
(
    '660e8400-e29b-41d4-a716-446655440002', 'bb1e8400-e29b-41d4-a716-446655440003', 'Database',
    8192, 4.00, 500, 'Finance Dept', 60.2, FALSE, 12288, 6.00, 750, 5120, 3.25, 320, 0.0985, 'active'
);



INSERT INTO team_management (team_name, team_description, team_lead_id, status, location) VALUES
('DevOps', 'Handles deployment, automation, and monitoring', NULL, 'Active', 'Remote'),
('Security', 'Manages security policies and compliance', NULL, 'Active', 'New York Data Center'),
('Engineering', 'Developers and software engineers', NULL, 'Active', 'San Francisco');

INSERT INTO team_members (team_id, role, email) VALUES
((SELECT team_id FROM team_management WHERE team_name = 'DevOps'), 'Engineer', 'devops_engineer@example.com'),
((SELECT team_id FROM team_management WHERE team_name = 'Security'), 'Security Analyst', 'security_analyst@example.com'),
((SELECT team_id FROM team_management WHERE team_name = 'Engineering'), 'Software Engineer', 'software_engineer@example.com');

INSERT INTO team_server_assignment (team_id, server_id) VALUES
((SELECT team_id FROM team_management WHERE team_name = 'DevOps'), '123e4567-e89b-12d3-a456-426614174000'),
((SELECT team_id FROM team_management WHERE team_name = 'Security'), '223e4567-e89b-12d3-a456-426614174001');


INSERT INTO user_access_logs (user_id, server_id, access_type, access_ip, user_agent) VALUES
('550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'READ', '192.168.1.1', 'Mozilla/5.0'),
('550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440003', 'WRITE', '203.0.113.42', 'Chrome/91.0'),
('550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440005', 'DELETE', '10.0.0.5', 'Safari/14.0');

