# What Queries Would Be Used?

Find all critical errors in the last 24 hours:

```sql
sql
CopyEdit
SELECT * FROM application_logs
WHERE log_level = 'CRITICAL'
AND log_timestamp >= NOW() - INTERVAL '24 hours';

```

- **Use Case**: This query retrieves all critical logs from the last 24 hours. It's useful for identifying **high-priority issues** that need immediate attention, such as system failures, database crashes, or security breaches.

Find logs for a specific application within a timeframe:

```sql
sql
CopyEdit
SELECT * FROM application_logs
WHERE app_name = 'web-api'
AND log_timestamp BETWEEN '2024-01-31 12:00:00' AND '2024-01-31 13:00:00';

```

- **Use Case**: This query filters logs for a particular application within a specific time range. It's useful for troubleshooting specific incidents or analyzing application behavior during particular periods (e.g., during peak traffic or after a deployment).

Count log entries per severity level:

```sql
sql
CopyEdit
SELECT log_level, COUNT(*)
FROM application_logs
GROUP BY log_level
ORDER BY COUNT(*) DESC;

```

- **Use Case**: This query provides a breakdown of log entries by their severity levels (DEBUG, INFO, WARN, ERROR, CRITICAL). It’s useful for identifying patterns in the logs, helping prioritize issues that need attention and understanding the general health of applications over time.

Find the top 10 most frequent errors from a specific application:

```sql
sql
CopyEdit
SELECT log_message, COUNT(*)
FROM application_logs
WHERE app_name = 'web-api'
AND log_level = 'ERROR'
GROUP BY log_message
ORDER BY COUNT(*) DESC
LIMIT 10;

```

- **Use Case**: This query identifies the most frequent errors occurring in a specific application. It’s useful for pinpointing common issues or recurring bugs that may require immediate fixes or long-term attention.

Get logs related to a specific server and correlate with server metrics:

```sql
sql
CopyEdit
SELECT al.log_timestamp, al.log_message, sm.cpu_usage, sm.memory_usage
FROM application_logs al
JOIN server_metrics sm ON al.server_id = sm.server_id
WHERE al.server_id = 'some-server-id'
AND al.log_timestamp BETWEEN '2024-01-30' AND '2024-01-31'
ORDER BY al.log_timestamp;

```

- **Use Case**: This query retrieves application logs along with server performance metrics for the same time period, helping correlate application issues with resource bottlenecks (e.g., high CPU or memory usage).

Find logs of a certain severity level for a given team or user:

```sql
sql
CopyEdit
SELECT * FROM application_logs al
JOIN user_access_logs ual ON al.server_id = ual.server_id
WHERE ual.team_id = 'team-id'
AND al.log_level = 'ERROR'
AND al.log_timestamp >= NOW() - INTERVAL '7 days';

```

- **Use Case**: This query links logs with user access data to track errors associated with specific teams or users. It’s useful for security or performance audits, helping identify whether certain actions or team activities are tied to application failures or errors.

Get logs related to a specific incident:

```sql
sql
CopyEdit
SELECT al.log_timestamp, al.log_message
FROM application_logs al
JOIN incident_response_logs irl ON al.log_id = irl.related_log_id
WHERE irl.incident_id = 'incident-id'
ORDER BY al.log_timestamp;

```

- **Use Case**: This query fetches logs associated with a specific incident, helping investigators track the sequence of events, identify application-level failures, and understand the context of the incident.

Count logs by application name and severity level:

```sql
sql
CopyEdit
SELECT app_name, log_level, COUNT(*)
FROM application_logs
GROUP BY app_name, log_level
ORDER BY app_name, log_level;

```

- **Use Case**: This query provides insights into the log distribution by severity level across various applications, enabling the identification of which apps are having the most issues or generating the most warnings and errors.

---

These queries help in **monitoring** and **troubleshooting applications** by efficiently analyzing large volumes of logs. They support use cases such as **incident detection**, **root cause analysis**, **cost optimization**, and **performance monitoring**, all essential for maintaining the health of applications and systems.