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
