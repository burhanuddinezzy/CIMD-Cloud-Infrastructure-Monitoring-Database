CREATE OR REPLACE FUNCTION check_high_cpu()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cpu_usage > 90 THEN
        RAISE NOTICE 'High CPU usage detected: %', NEW.cpu_usage;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_high_cpu
BEFORE INSERT OR UPDATE ON server_metrics
FOR EACH ROW EXECUTE FUNCTION check_high_cpu();


CREATE OR REPLACE FUNCTION check_high_error_rate() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.error_rate > 5.00 THEN
        RAISE NOTICE 'Warning: High error rate detected for server %!', NEW.server_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER error_rate_check
BEFORE INSERT OR UPDATE ON aggregated_metrics
FOR EACH ROW EXECUTE FUNCTION check_high_error_rate();


-- 07_triggers.sql - Automatic Actions
CREATE OR REPLACE FUNCTION notify_high_severity_alerts() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.alert_severity = 'CRITICAL' THEN
        RAISE NOTICE 'Critical alert detected: %', NEW.alert_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER high_severity_alert_check
BEFORE INSERT OR UPDATE ON alert_history
FOR EACH ROW EXECUTE FUNCTION notify_high_severity_alerts();



-- 07_triggers.sql - Triggers for automation
CREATE OR REPLACE FUNCTION log_alert_update() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO alert_log (alert_config_id, action, changed_at)
    VALUES (NEW.alert_config_id, 'UPDATED', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER alert_update_trigger
AFTER UPDATE ON alert_configuration
FOR EACH ROW EXECUTE FUNCTION log_alert_update();



-- 07_triggers.sql - Triggers for automation
CREATE FUNCTION log_security_alert() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.log_source = 'SECURITY' AND NEW.log_level = 'CRITICAL' THEN
        INSERT INTO security_alerts (log_id, server_id, log_timestamp, description)
        VALUES (NEW.log_id, NEW.server_id, NEW.log_timestamp, 'Critical security log detected');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_security_alert
AFTER INSERT ON application_logs
FOR EACH ROW EXECUTE FUNCTION log_security_alert();


-- 07_triggers.sql - Triggers for automation
CREATE OR REPLACE FUNCTION update_cost_adjustment() RETURNS TRIGGER AS $$
BEGIN
    NEW.cost_adjustment := NEW.cost_per_hour * 24 * 30 - NEW.total_monthly_cost;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cost_adjustment_trigger
BEFORE INSERT OR UPDATE ON cost_data
FOR EACH ROW EXECUTE FUNCTION update_cost_adjustment();




-- 07_triggers.sql - Triggers for automation
CREATE OR REPLACE FUNCTION update_downtime_duration() RETURNS TRIGGER AS $$
BEGIN
    NEW.downtime_duration_minutes := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_downtime_duration
BEFORE UPDATE ON downtime_logs
FOR EACH ROW
WHEN (NEW.end_time IS NOT NULL)
EXECUTE FUNCTION update_downtime_duration();




-- Trigger to log when an error is resolved
CREATE OR REPLACE FUNCTION log_error_resolution()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.resolved = TRUE AND OLD.resolved = FALSE THEN
        INSERT INTO error_resolution_logs (error_id, server_id, resolved_at, resolution_action)
        VALUES (NEW.error_id, NEW.server_id, NOW(), NEW.recovery_action);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_error_resolution
AFTER UPDATE ON error_logs
FOR EACH ROW
WHEN (OLD.resolved = FALSE AND NEW.resolved = TRUE)
EXECUTE FUNCTION log_error_resolution();




-- Trigger to set resolved_at timestamp when an incident is marked as resolved
CREATE OR REPLACE FUNCTION set_resolved_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Resolved' AND OLD.status != 'Resolved' THEN
        NEW.resolved_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_resolved_timestamp
BEFORE UPDATE ON incident_response_logs
FOR EACH ROW
WHEN (NEW.status = 'Resolved')
EXECUTE FUNCTION set_resolved_timestamp();



-- Trigger to update last_updated timestamp on modification
CREATE TRIGGER update_last_modified
BEFORE UPDATE ON resource_allocation
FOR EACH ROW
EXECUTE FUNCTION set_last_modified();

-- Function to set the last_updated timestamp
CREATE FUNCTION set_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
