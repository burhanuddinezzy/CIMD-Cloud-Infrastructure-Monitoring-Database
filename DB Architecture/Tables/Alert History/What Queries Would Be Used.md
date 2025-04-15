# What Queries Would Be Used?

Find all unresolved alerts for a given server:

```sql
sql
CopyEdit
SELECT * FROM alert_history
WHERE server_id = 's1a2b3' AND alert_status = 'OPEN';

```

Find the most frequent alert types in the last 30 days:

```sql
sql
CopyEdit
SELECT alert_type, COUNT(*) AS alert_count
FROM alert_history
WHERE alert_triggered_at >= NOW() - INTERVAL 30 DAY
GROUP BY alert_type
ORDER BY alert_count DESC;

```

Calculate the average resolution time for alerts:

```sql
sql
CopyEdit
SELECT AVG(TIMESTAMPDIFF(MINUTE, alert_triggered_at, resolved_at)) AS avg_resolution_time
FROM alert_history
WHERE resolved_at IS NOT NULL;

```

Find servers with the highest number of alerts in the past week:

```sql
sql
CopyEdit
SELECT server_id, COUNT(*) AS alert_count
FROM alert_history
WHERE alert_triggered_at >= NOW() - INTERVAL 7 DAY
GROUP BY server_id
ORDER BY alert_count DESC
LIMIT 10;

```

Identify servers with unresolved alerts older than 24 hours:

```sql
sql
CopyEdit
SELECT server_id, alert_id, alert_triggered_at
FROM alert_history
WHERE alert_status = 'OPEN'
AND alert_triggered_at <= NOW() - INTERVAL 1 DAY;

```

Track alert resolution trends over time:

```sql
sql
CopyEdit
SELECT DATE(alert_triggered_at) AS alert_date, COUNT(*) AS total_alerts,
       COUNT(resolved_at) AS resolved_alerts
FROM alert_history
GROUP BY alert_date
ORDER BY alert_date DESC;

```

Check if alerts correlate with downtime incidents:

```sql
sql
CopyEdit
SELECT ah.alert_id, ah.server_id, ah.alert_type, dl.downtime_start, dl.downtime_end
FROM alert_history ah
JOIN downtime_logs dl ON ah.server_id = dl.server_id
WHERE ah.alert_triggered_at BETWEEN dl.downtime_start AND dl.downtime_end;

```

Analyze how many alerts escalate into actual errors:

```sql
sql
CopyEdit
SELECT ah.alert_type, COUNT(DISTINCT ah.alert_id) AS total_alerts,
       COUNT(el.error_id) AS associated_errors
FROM alert_history ah
LEFT JOIN error_logs el ON ah.server_id = el.server_id
AND ah.alert_triggered_at BETWEEN el.error_timestamp - INTERVAL 5 MINUTE
AND el.error_timestamp + INTERVAL 5 MINUTE
GROUP BY ah.alert_type
ORDER BY associated_errors DESC;

```

Identify recurring alerts for proactive issue resolution:

```sql
sql
CopyEdit
SELECT server_id, alert_type, COUNT(*) AS occurrences
FROM alert_history
WHERE alert_triggered_at >= NOW() - INTERVAL 60 DAY
GROUP BY server_id, alert_type
HAVING occurrences > 3
ORDER BY occurrences DESC;

```

### **How These Queries Help**

- **Optimizing system monitoring**: Queries like tracking recurring alerts or checking for unresolved alerts help in **proactive issue resolution**.
- **Incident management efficiency**: Analyzing **resolution time trends** helps in identifying **SLA performance** and improving **response times**.
- **Correlating alerts with downtime & errors**: Helps in identifying **which alerts are most critical** and require **immediate action**.
- **Improving cost efficiency**: If alerts frequently correlate with errors and downtime, this can help **prevent financial losses due to service outages**.

Would you like to add any automation that runs these queries periodically?

4o