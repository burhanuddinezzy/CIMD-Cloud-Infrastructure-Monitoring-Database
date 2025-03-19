CREATE TABLE server_metrics (
    server_id UUID PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    cpu_usage FLOAT NOT NULL,
    memory_usage FLOAT NOT NULL,
    disk_read_ops_per_sec INTEGER NOT NULL,
    disk_write_ops_per_sec INTEGER NOT NULL,
    network_in_bytes BIGINT NOT NULL,
    network_out_bytes BIGINT NOT NULL,
    uptime_in_mins INTEGER NOT NULL,
    latency_in_ms FLOAT NOT NULL,
    db_queries_per_sec INTEGER NOT NULL,
    disk_usage_percent FLOAT NOT NULL,
    error_count INTEGER NULL,
    disk_read_throughput BIGINT NOT NULL,
    disk_write_throughput BIGINT NOT NULL
);

CREATE TABLE aggregated_metrics (
    server_id UUID REFERENCES servers(server_id) ON DELETE CASCADE,
    region VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    hourly_avg_cpu_usage DECIMAL(5,2) NOT NULL,
    hourly_avg_memory_usage DECIMAL(5,2) NOT NULL,
    peak_network_usage BIGINT NOT NULL,
    peak_disk_usage BIGINT NOT NULL,
    uptime_percentage DECIMAL(5,2) NOT NULL,
    total_requests BIGINT NOT NULL,
    error_rate DECIMAL(5,2) NOT NULL,
    average_response_time DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (server_id, timestamp)
);

-- 01_create_tables.sql - Create Alert History Table
CREATE TABLE alert_history (
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID REFERENCES servers(server_id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL,
    threshold_value DECIMAL(10,2) NOT NULL,
    alert_triggered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP NULL,
    alert_status VARCHAR(10) CHECK (alert_status IN ('OPEN', 'CLOSED')) NOT NULL,
    alert_severity VARCHAR(10) CHECK (alert_severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) NOT NULL,
    alert_description TEXT,
    resolved_by VARCHAR(100),
    alert_source VARCHAR(100),
    impact VARCHAR(50)
);
