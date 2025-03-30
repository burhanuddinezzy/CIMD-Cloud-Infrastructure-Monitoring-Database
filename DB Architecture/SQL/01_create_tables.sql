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



-- 01_create_tables.sql - Defines the alert_configuration table
CREATE TABLE alert_configuration (
    alert_config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL,
    metric_name VARCHAR(50) NOT NULL,
    threshold_value FLOAT NOT NULL,
    alert_frequency INTERVAL NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    alert_enabled BOOLEAN DEFAULT TRUE,
    alert_type TEXT CHECK (alert_type IN ('EMAIL', 'SMS', 'WEBHOOK', 'SLACK')) NOT NULL,
    severity_level TEXT CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) NOT NULL,
    FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE
);




-- 01_create_tables.sql - Defines the application_logs table
CREATE TABLE application_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL REFERENCES servers(server_id) ON DELETE CASCADE,
    app_name VARCHAR(255) NOT NULL,
    log_level ENUM('DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL') NOT NULL,
    error_code VARCHAR(50),
    log_timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
    trace_id UUID,
    span_id UUID,
    source_ip INET,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    log_source ENUM('APP', 'DATABASE', 'SECURITY', 'SYSTEM') NOT NULL
);



-- 01_create_tables.sql - Defines the cost_data table
CREATE TABLE cost_data (
    server_id UUID NOT NULL,
    region VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    cost_per_hour DECIMAL(10,2) NOT NULL,
    total_monthly_cost DECIMAL(10,2) NOT NULL,
    team_allocation VARCHAR(50),
    cost_per_day DECIMAL(10,2),
    cost_type VARCHAR(50),
    cost_adjustment DECIMAL(10,2),
    cost_adjustment_reason TEXT,
    cost_basis VARCHAR(50),
    PRIMARY KEY (server_id, timestamp),
    FOREIGN KEY (server_id) REFERENCES servers(server_id) ON DELETE CASCADE
);

-- 01_create_tables.sql - Defines the downtime_logs table
CREATE TABLE downtime_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL REFERENCES servers(server_id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    downtime_duration_minutes INTEGER GENERATED ALWAYS AS 
        (EXTRACT(EPOCH FROM (end_time - start_time)) / 60) STORED,
    downtime_cause VARCHAR(255) NOT NULL,
    sla_tracking BOOLEAN NOT NULL,
    incident_id UUID NULL REFERENCES incident_management(incident_id) ON DELETE SET NULL,
    is_planned BOOLEAN NOT NULL,
    recovery_action VARCHAR(255) NOT NULL
);


CREATE TABLE error_logs (
    error_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    error_severity TEXT CHECK (error_severity IN ('INFO', 'WARNING', 'CRITICAL')) NOT NULL,
    error_message TEXT NOT NULL,
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    resolved_at TIMESTAMP NULL,
    incident_id UUID NULL,
    error_source VARCHAR(100) NOT NULL,
    error_code VARCHAR(50) NULL,
    recovery_action VARCHAR(255) NULL,
    FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE,
    FOREIGN KEY (incident_id) REFERENCES incident_management(incident_id) ON DELETE SET NULL
);




CREATE TABLE incident_response_logs (
    incident_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    response_team_id UUID NOT NULL,
    incident_summary TEXT NOT NULL,
    resolution_time_minutes INTEGER CHECK (resolution_time_minutes >= 0) NULL,
    status VARCHAR(50) CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Escalated')) NOT NULL DEFAULT 'Open',
    priority_level VARCHAR(20) CHECK (priority_level IN ('Low', 'Medium', 'High', 'Critical')) NOT NULL DEFAULT 'Medium',
    incident_type VARCHAR(100) NOT NULL,
    root_cause TEXT NULL,
    escalation_flag BOOLEAN NOT NULL DEFAULT FALSE,
    audit_log_id UUID NULL,
    FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE,
    FOREIGN KEY (response_team_id) REFERENCES team_management(team_id) ON DELETE SET NULL,
    FOREIGN KEY (audit_log_id) REFERENCES user_access_logs(audit_log_id) ON DELETE SET NULL
);



CREATE TABLE resource_allocation (
    server_id UUID NOT NULL,
    app_id UUID NOT NULL,
    workload_type VARCHAR(50) NOT NULL,
    allocated_memory INTEGER NOT NULL, -- in MB or GB
    allocated_cpu DECIMAL(5,2) NOT NULL, -- in Cores or %
    allocated_disk_space INTEGER NOT NULL, -- in GB
    resource_tag VARCHAR(100),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    utilization_percentage DECIMAL(5,2),
    autoscaling_enabled BOOLEAN DEFAULT FALSE,
    max_allocated_memory INTEGER, -- peak memory usage
    max_allocated_cpu DECIMAL(5,2), -- peak CPU usage
    max_allocated_disk_space INTEGER, -- peak disk usage
    actual_memory_usage INTEGER, -- real-time usage
    actual_cpu_usage DECIMAL(5,2), -- real-time CPU usage
    actual_disk_usage INTEGER, -- real-time disk usage
    cost_per_hour DECIMAL(10,4) NOT NULL, -- cost per hour
    allocation_status VARCHAR(20) CHECK (allocation_status IN ('active', 'pending', 'deallocated')),
    PRIMARY KEY (server_id, app_id),
    FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE,
    FOREIGN KEY (app_id) REFERENCES applications(app_id) ON DELETE CASCADE
);



CREATE TABLE team_management (
    team_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_name VARCHAR(100) NOT NULL UNIQUE,
    team_description TEXT,
    team_lead_id UUID REFERENCES team_members(member_id) ON DELETE SET NULL,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Active', 'Inactive', 'Pending')),
    location VARCHAR(100)
);

CREATE TABLE team_members (
    member_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES team_management(team_id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE team_server_assignment (
    team_id UUID REFERENCES team_management(team_id) ON DELETE CASCADE,
    server_id UUID REFERENCES servers(server_id) ON DELETE CASCADE,
    PRIMARY KEY (team_id, server_id)
);

CREATE TABLE user_access_logs (
    access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    server_id UUID NOT NULL REFERENCES servers(server_id) ON DELETE CASCADE,
    access_type VARCHAR(10) CHECK (access_type IN ('READ', 'WRITE', 'DELETE', 'EXECUTE')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    access_ip VARCHAR(45) NOT NULL,
    user_agent VARCHAR(255) NOT NULL
);
