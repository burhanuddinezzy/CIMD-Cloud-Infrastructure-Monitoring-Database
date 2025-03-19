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
