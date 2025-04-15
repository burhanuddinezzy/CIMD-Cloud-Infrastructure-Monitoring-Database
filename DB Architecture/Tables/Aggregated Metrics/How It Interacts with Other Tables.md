# How It Interacts with Other Tables

- **Joins with `server_metrics`** to pull raw data for aggregation.
    - **Why?** The `server_metrics` table contains detailed, high-frequency performance logs. Aggregating this raw data into hourly summaries reduces query load and enhances system performance.
    - **How?** The aggregation process calculates averages (CPU, memory), peaks (network, disk), and totals (requests, errors) from `server_metrics` over fixed time intervals.
    - **Example Query:**
        
        ```sql
        sql
        CopyEdit
        SELECT
            sm.server_id,
            sm.region,
            AVG(sm.cpu_usage) AS hourly_avg_cpu_usage,
            AVG(sm.memory_usage) AS hourly_avg_memory_usage,
            MAX(sm.network_usage) AS peak_network_usage,
            MAX(sm.disk_usage) AS peak_disk_usage
        FROM server_metrics sm
        WHERE sm.timestamp >= NOW() - INTERVAL 1 HOUR
        GROUP BY sm.server_id, sm.region;
        
        ```
        
- **Joins with `downtime_logs`** to calculate uptime percentages.
    - **Why?** The `downtime_logs` table records when a server goes offline. By cross-referencing these logs with performance metrics, we can determine availability percentages.
    - **How?** The system calculates uptime percentage by subtracting downtime duration from the total interval duration.
    - **Example Query:**
        
        ```sql
        sql
        CopyEdit
        SELECT
            am.server_id,
            am.region,
            (1 - (COALESCE(SUM(dl.downtime_duration), 0) / 3600)) * 100 AS uptime_percentage
        FROM aggregated_metrics am
        LEFT JOIN downtime_logs dl
        ON am.server_id = dl.server_id
        AND dl.downtime_start >= NOW() - INTERVAL 1 HOUR
        GROUP BY am.server_id, am.region;
        
        ```
        
- **Joins with `cost_data`** to analyze cost-performance efficiency.
    - **Why?** Cloud providers charge based on CPU, memory, storage, and network usage. Correlating cost data with performance metrics helps optimize resource allocation and minimize costs.
    - **How?** By joining with `cost_data`, we can compare hourly costs against resource usage to identify inefficiencies.
    - **Example Query:**
        
        ```sql
        sql
        CopyEdit
        SELECT
            am.server_id,
            am.region,
            am.hourly_avg_cpu_usage,
            am.hourly_avg_memory_usage,
            am.peak_network_usage,
            am.peak_disk_usage,
            cd.hourly_cost,
            (am.hourly_avg_cpu_usage / cd.hourly_cost) AS cpu_cost_efficiency,
            (am.hourly_avg_memory_usage / cd.hourly_cost) AS memory_cost_efficiency
        FROM aggregated_metrics am
        JOIN cost_data cd
        ON am.server_id = cd.server_id
        WHERE cd.timestamp >= NOW() - INTERVAL 1 HOUR;
        
        ```
        

### **Additional Interactions with Other Tables**

- **Joins with `alert_history`** to detect performance anomalies.
    - **Why?** High CPU, memory, or network spikes could trigger alerts. Linking aggregated metrics with `alert_history` allows correlation of resource usage with system warnings.
    - **Example:** Identifying servers with high CPU usage that triggered alerts.
        
        ```sql
        sql
        CopyEdit
        SELECT am.server_id, am.hourly_avg_cpu_usage, ah.alert_type, ah.alert_status
        FROM aggregated_metrics am
        JOIN alert_history ah
        ON am.server_id = ah.server_id
        AND ah.alert_triggered_at >= NOW() - INTERVAL 1 HOUR
        WHERE am.hourly_avg_cpu_usage > 90;
        
        ```
        
- **Joins with `scaling_events`** to assess auto-scaling efficiency.
    - **Why?** If auto-scaling is enabled, tracking whether scaling events align with high resource utilization helps optimize policies.
    - **Example Query:** Checking if auto-scaling occurred when CPU usage exceeded 80%.
        
        ```sql
        sql
        CopyEdit
        SELECT se.server_id, se.scaling_action, am.hourly_avg_cpu_usage
        FROM scaling_events se
        JOIN aggregated_metrics am
        ON se.server_id = am.server_id
        AND se.timestamp >= NOW() - INTERVAL 1 HOUR
        WHERE am.hourly_avg_cpu_usage > 80;
        
        ```
        

These additional interactions enhance the **usability** of aggregated metrics for **trend analysis, cost optimization, incident management, and auto-scaling efficiency tracking.**