ALTER TABLE server_metrics ADD COLUMN io_wait FLOAT NULL;
ALTER TABLE server_metrics DROP COLUMN error_count;
