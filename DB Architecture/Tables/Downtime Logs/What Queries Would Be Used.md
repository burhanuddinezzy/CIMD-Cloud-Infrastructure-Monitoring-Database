# What Queries Would Be Used?

Retrieve all downtime events longer than 1 hour:

```sql
sql
CopyEdit
SELECT * FROM downtime_logs WHERE downtime_duration_minutes > 60;

```

Calculate total downtime per server in the last month:

```sql
sql
CopyEdit
SELECT server_id, SUM(downtime_duration_minutes) AS total_downtime
FROM downtime_logs
WHERE start_time >= NOW() - INTERVAL '1 month'
GROUP BY server_id;

```

Find downtime events that violated SLA:

```sql
sql
CopyEdit
SELECT * FROM downtime_logs WHERE sla_tracking = TRUE;

```

Identify servers with the highest number of downtime incidents in the last 3 months:

```sql
sql
CopyEdit
SELECT server_id, COUNT(*) AS downtime_count
FROM downtime_logs
WHERE start_time >= NOW() - INTERVAL '3 months'
GROUP BY server_id
ORDER BY downtime_count DESC
LIMIT 10;

```

Retrieve the most recent downtime event for each server:

```sql
sql
CopyEdit
SELECT DISTINCT ON (server_id) server_id, downtime_id, start_time, end_time, downtime_duration_minutes
FROM downtime_logs
ORDER BY server_id, start_time DESC;

```

List downtime events where services restarted automatically due to an error:

```sql
sql
CopyEdit
SELECT d.*, e.error_message
FROM downtime_logs d
JOIN error_logs e ON d.server_id = e.server_id
WHERE e.auto_restart_triggered = TRUE;

```

Find the longest single downtime event in the last year:

```sql
sql
CopyEdit
SELECT * FROM downtime_logs
WHERE start_time >= NOW() - INTERVAL '1 year'
ORDER BY downtime_duration_minutes DESC
LIMIT 1;

```

Calculate average downtime per server in the last 6 months:

```sql
sql
CopyEdit
SELECT server_id, AVG(downtime_duration_minutes) AS avg_downtime
FROM downtime_logs
WHERE start_time >= NOW() - INTERVAL '6 months'
GROUP BY server_id;

```

Find downtime incidents that happened outside business hours (e.g., 9 AM - 5 PM):

```sql
sql
CopyEdit
SELECT * FROM downtime_logs
WHERE EXTRACT(HOUR FROM start_time) < 9 OR EXTRACT(HOUR FROM start_time) > 17;

```

By optimizing these queries, the system ensures efficient tracking, analysis, and response to downtime incidents. 🚀