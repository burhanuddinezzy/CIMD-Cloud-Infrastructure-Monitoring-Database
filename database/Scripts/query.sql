select * from server_metrics;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_level_enum') THEN
        CREATE TYPE log_level_enum AS ENUM (
            'DEBUG', 'INFO', 'NOTICE', 'WARNING', 'ERROR', 'CRITICAL', 'ALERT', 'EMERGENCY'
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_source_enum') THEN
        CREATE TYPE log_source_enum AS ENUM (
            'APP', 'SYSTEM', 'SECURITY', 'NETWORK', 'DATABASE', 'API', 'USER', 'SCHEDULER', 'MONITOR'
        );
    END IF;
END$$;