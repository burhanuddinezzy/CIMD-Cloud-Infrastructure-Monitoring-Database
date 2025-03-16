CREATE INDEX idx_server_metrics_region ON server_metrics(region);
CREATE INDEX idx_server_metrics_cpu_usage ON server_metrics(cpu_usage);
CREATE INDEX idx_server_metrics_memory_usage ON server_metrics(memory_usage);


CREATE INDEX idx_aggregated_metrics_region ON aggregated_metrics(region);
CREATE INDEX idx_aggregated_metrics_timestamp ON aggregated_metrics(timestamp);
