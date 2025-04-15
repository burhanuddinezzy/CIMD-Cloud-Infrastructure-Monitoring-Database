# Query Use Cases for Incident Response Logs

The **Incident Response Logs** table is crucial for tracking **incident trends, team performance, and root cause analysis**. Below are essential queries used for monitoring and improving incident response efficiency.

### **1. Team Performance & Efficiency Queries**

### **Find all incidents handled by a specific team**

This query retrieves **all incidents a specific team responded to**, helping track workload distribution.

```sql
sql
CopyEdit
SELECT * FROM incident_response_logs
WHERE response_team_id = 'team-001'
ORDER BY timestamp DESC;

```

🔹 **Use Case:** Understanding which teams handle the most incidents.

### **Get the average resolution time per team**

This helps measure **which teams resolve incidents the fastest**.

```sql
sql
CopyEdit
SELECT t.team_name, AVG(i.resolution_time_minutes) AS avg_resolution_time
FROM incident_response_logs i
JOIN team_management t ON i.response_team_id = t.team_id
GROUP BY t.team_name
ORDER BY avg_resolution_time ASC;

```

🔹 **Use Case:** Identifying teams that need process improvements or more resources.

### **Find the slowest-resolving incidents (top 5 longest resolution times)**

This identifies incidents that took an unusually long time to resolve.

```sql
sql
CopyEdit
SELECT * FROM incident_response_logs
ORDER BY resolution_time_minutes DESC
LIMIT 5;

```

🔹 **Use Case:** Analyzing **why some incidents took too long** and improving response workflows.

### **2. Server Health & Impact Analysis Queries**

### **Retrieve all incidents for a specific server**

This shows the **history of incidents affecting a particular server**.

```sql
sql
CopyEdit
SELECT * FROM incident_response_logs
WHERE server_id = 'srv-101'
ORDER BY timestamp DESC;

```

🔹 **Use Case:** Checking if **a server is experiencing recurring issues**.

### **Find servers with the highest number of incidents**

This query helps identify **problematic servers** that may need upgrades or better monitoring.

```sql
sql
CopyEdit
SELECT s.server_id, s.server_name, COUNT(i.incident_id) AS total_incidents
FROM incident_response_logs i
JOIN server_metrics s ON i.server_id = s.server_id
GROUP BY s.server_id, s.server_name
ORDER BY total_incidents DESC
LIMIT 10;

```

🔹 **Use Case:** Identifying **servers that frequently experience failures** and need proactive maintenance.

### **Correlate server incidents with CPU spikes**

This query checks if **high CPU usage** is linked to incidents.

```sql
sql
CopyEdit
SELECT s.server_id, s.cpu_usage, i.incident_summary, i.timestamp
FROM server_metrics s
JOIN incident_response_logs i ON s.server_id = i.server_id
WHERE i.timestamp BETWEEN s.timestamp - INTERVAL '5 minutes' AND s.timestamp + INTERVAL '5 minutes'
AND s.cpu_usage > 85;

```

🔹 **Use Case:** Detecting whether **resource exhaustion** is a common cause of incidents.

### **3. Alert & Monitoring Queries**

### **Find incidents that were not triggered by an alert**

This identifies **incidents where alerts failed to trigger**, helping improve monitoring rules.

```sql
sql
CopyEdit
SELECT i.incident_id, i.incident_summary, a.alert_id
FROM incident_response_logs i
LEFT JOIN alert_history a
ON i.server_id = a.server_id
AND i.timestamp BETWEEN a.timestamp - INTERVAL '2 minutes' AND a.timestamp + INTERVAL '2 minutes'
WHERE a.alert_id IS NULL;

```

🔹 **Use Case:** Improving **alerting accuracy** and reducing **missed incidents**.

### **Match alerts with actual incidents**

This links alerts to real incidents, validating **how effective alerts are**.

```sql
sql
CopyEdit
SELECT a.alert_type, COUNT(i.incident_id) AS matched_incidents
FROM alert_history a
JOIN incident_response_logs i
ON a.server_id = i.server_id
AND i.timestamp BETWEEN a.timestamp - INTERVAL '2 minutes' AND a.timestamp + INTERVAL '2 minutes'
GROUP BY a.alert_type;

```

🔹 **Use Case:** Ensuring **alerting systems are detecting real issues** instead of false positives.

### **4. Cost & Financial Impact Queries**

### **Estimate financial loss per incident due to downtime**

This query calculates **how much each incident costs in lost revenue**.

```sql
sql
CopyEdit
SELECT i.incident_id, i.incident_summary, c.monthly_cost,
       (i.resolution_time_minutes / 60.0) * (c.monthly_cost / 730) AS estimated_downtime_cost
FROM incident_response_logs i
JOIN cost_data c ON i.server_id = c.server_id;

```

🔹 **Use Case:** Justifying **investments in better infrastructure** to minimize losses.

### **Find the most expensive incidents**

This identifies **incidents that caused the highest financial impact**.

```sql
sql
CopyEdit
SELECT i.incident_id, i.incident_summary,
       (i.resolution_time_minutes / 60.0) * (c.monthly_cost / 730) AS estimated_downtime_cost
FROM incident_response_logs i
JOIN cost_data c ON i.server_id = c.server_id
ORDER BY estimated_downtime_cost DESC
LIMIT 5;

```

🔹 **Use Case:** Prioritizing **which types of failures need urgent fixes** based on cost impact.

### **5. Security & Compliance Queries**

### **Check which users accessed a server before an incident**

This helps identify if **a user action caused a failure**.

```sql
sql
CopyEdit
SELECT u.user_id, u.access_time, i.incident_id, i.incident_summary
FROM user_access_logs u
JOIN incident_response_logs i
ON u.server_id = i.server_id
AND i.timestamp BETWEEN u.access_time - INTERVAL '5 minutes' AND u.access_time + INTERVAL '5 minutes';

```

🔹 **Use Case:** Detecting **unauthorized actions or misconfigurations** leading to incidents.

### **Find incidents linked to unauthorized access attempts**

This helps **detect security breaches** that caused system failures.

```sql
sql
CopyEdit
SELECT i.incident_id, i.incident_summary, u.user_id, u.access_type
FROM incident_response_logs i
JOIN user_access_logs u
ON i.server_id = u.server_id
WHERE u.access_type = 'unauthorized'
ORDER BY i.timestamp DESC;

```

🔹 **Use Case:** Strengthening **incident response for security-related failures**.

### **Summary of Key Query Use Cases**

| Query Type | Purpose |
| --- | --- |
| **Team Performance Queries** | Identify high/low-performing teams based on response time and workload. |
| **Server Impact Queries** | Track recurring issues on specific servers and correlate them with resource usage. |
| **Alert Analysis Queries** | Ensure alerts are properly detecting real issues. |
| **Cost Impact Queries** | Estimate financial losses from downtime and prioritize fixes. |
| **Security & Compliance Queries** | Detect unauthorized access or user actions causing incidents. |

These queries **transform raw incident logs into actionable insights**, improving **incident response, monitoring accuracy, cost efficiency, and security**. 🚀