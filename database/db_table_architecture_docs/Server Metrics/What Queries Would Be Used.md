# What Queries Would Be Used?

### **1. Identifying Performance Issues**

- **Find servers with high CPU usage:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, cpu_usage, timestamp
    FROM server_metrics
    WHERE cpu_usage > 90;
    
    ```
    
    **Use Case:** Detect overloaded servers that might require scaling or troubleshooting.
    
- **Get average latency per region:**
    
    ```sql
    sql
    CopyEdit
    SELECT region, AVG(latency_in_ms) AS avg_latency
    FROM server_metrics
    GROUP BY region;
    
    ```
    
    **Use Case:** Identify regions experiencing slow response times and optimize performance accordingly.
    
- **Find servers with frequent downtime (e.g., more than 3 downtimes in the past week):**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, COUNT(*) AS downtime_count
    FROM downtime_logs
    WHERE timestamp >= NOW() - INTERVAL '7 days'
    GROUP BY server_id
    HAVING COUNT(*) > 3;
    
    ```
    
    **Use Case:** Spot unstable servers that may need infrastructure improvements.
    
- **Check if high disk operations are impacting CPU performance:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, cpu_usage, disk_read_ops_per_sec, disk_write_ops_per_sec
    FROM server_metrics
    WHERE cpu_usage > 85 AND (disk_read_ops_per_sec > 5000 OR disk_write_ops_per_sec > 5000);
    
    ```
    
    **Use Case:** Identify servers where disk I/O bottlenecks might be causing high CPU load.
    

### **2. Monitoring Network Traffic & Security**

- **Find servers with unusually high outbound traffic (possible data breach or DDoS attack):**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, network_out_bytes, timestamp
    FROM server_metrics
    WHERE network_out_bytes > (SELECT AVG(network_out_bytes) * 3 FROM server_metrics);
    
    ```
    
    **Use Case:** Detect servers sending excessive data, which could indicate a security risk.
    
- **Identify network congestion by checking top traffic-consuming servers:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, SUM(network_in_bytes + network_out_bytes) AS total_traffic
    FROM server_metrics
    WHERE timestamp >= NOW() - INTERVAL '1 hour'
    GROUP BY server_id
    ORDER BY total_traffic DESC
    LIMIT 10;
    
    ```
    
    **Use Case:** Determine which servers are consuming the most bandwidth.
    

### **3. Resource Allocation & Cost Optimization**

- **Identify underutilized servers that can be scaled down to reduce costs:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, cpu_usage, memory_usage
    FROM server_metrics
    WHERE cpu_usage < 10 AND memory_usage < 20;
    
    ```
    
    **Use Case:** Identify low-usage servers that could be deallocated to save on costs.
    
- **Check total estimated cost per server based on usage:**
    
    ```sql
    sql
    CopyEdit
    SELECT sm.server_id,
           SUM(cd.compute_cost + cd.storage_cost + cd.network_cost) AS total_cost
    FROM server_metrics sm
    JOIN cost_data cd ON sm.server_id = cd.server_id
    GROUP BY sm.server_id
    ORDER BY total_cost DESC;
    
    ```
    
    **Use Case:** Identify cost-heavy servers to optimize spending.
    
- **Find servers with high alert frequency (potential chronic issues):**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, COUNT(*) AS alert_count
    FROM alert_history
    WHERE timestamp >= NOW() - INTERVAL '30 days'
    GROUP BY server_id
    ORDER BY alert_count DESC
    LIMIT 10;
    
    ```
    
    **Use Case:** Identify servers experiencing frequent issues that require deeper investigation.
    

### **4. Incident Response & Troubleshooting**

- **Check logs related to a specific server during a high-usage event:**
    
    ```sql
    sql
    CopyEdit
    SELECT sm.server_id, sm.cpu_usage, sm.memory_usage, el.error_message, el.timestamp
    FROM server_metrics sm
    JOIN error_logs el ON sm.server_id = el.server_id
    WHERE sm.cpu_usage > 90
    AND sm.timestamp BETWEEN NOW() - INTERVAL '1 hour' AND NOW();
    
    ```
    
    **Use Case:** Correlate system errors with high resource utilization for troubleshooting.
    
- **Find servers that triggered alerts but have no corresponding incidents recorded:**
    
    ```sql
    sql
    CopyEdit
    SELECT ah.server_id, ah.alert_type, ah.timestamp
    FROM alert_history ah
    LEFT JOIN incident_response_logs ir ON ah.server_id = ir.server_id AND ah.timestamp = ir.timestamp
    WHERE ir.server_id IS NULL;
    
    ```
    
    **Use Case:** Ensure that every alert is properly investigated and documented in incident response logs.
    
- **Find the most common types of incidents in the past 6 months:**
    
    ```sql
    sql
    CopyEdit
    SELECT incident_type, COUNT(*) AS occurrence_count
    FROM incident_response_logs
    WHERE timestamp >= NOW() - INTERVAL '6 months'
    GROUP BY incident_type
    ORDER BY occurrence_count DESC;
    
    ```
    
    **Use Case:** Identify recurring issues to address systemic problems.
    

### **5. User Activity & Access Logs**

- **Find users who accessed a server before a crash (potentially linked to unauthorized access):**
    
    ```sql
    sql
    CopyEdit
    SELECT ual.user_id, ual.server_id, ual.timestamp
    FROM user_access_logs ual
    JOIN downtime_logs dl ON ual.server_id = dl.server_id
    WHERE dl.timestamp BETWEEN ual.timestamp AND ual.timestamp + INTERVAL '10 minutes';
    
    ```
    
    **Use Case:** Identify whether user actions caused or coincided with system failures.
    
- **Get the most active users by number of server accesses:**
    
    ```sql
    sql
    CopyEdit
    SELECT user_id, COUNT(*) AS access_count
    FROM user_access_logs
    WHERE timestamp >= NOW() - INTERVAL '30 days'
    GROUP BY user_id
    ORDER BY access_count DESC
    LIMIT 10;
    
    ```
    
    **Use Case:** Identify heavy users or potential abuse of system resources.
    
- **Find the most frequently accessed servers in the past week:**
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, COUNT(*) AS access_count
    FROM user_access_logs
    WHERE timestamp >= NOW() - INTERVAL '7 days'
    GROUP BY server_id
    ORDER BY access_count DESC
    LIMIT 10;
    
    ```
    
    **Use Case:** Identify popular servers that might require more resources.