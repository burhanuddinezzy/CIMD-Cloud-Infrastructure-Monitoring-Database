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











