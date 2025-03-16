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

