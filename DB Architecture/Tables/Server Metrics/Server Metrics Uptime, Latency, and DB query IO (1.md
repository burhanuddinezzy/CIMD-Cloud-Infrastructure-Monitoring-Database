# Server Metrics: Uptime, Latency, and DB query IO (1)

### **Tracking Uptime (`uptime_in_mins` as INTEGER)**

### **Purpose**

- Tracks how long a server has been running continuously without downtime.
- Helps in reliability monitoring and detecting potential issues like crashes, reboots, or hardware failures.
- Provides a simple metric for system administrators to gauge system health.

### **Why Track Uptime?**

- **Early Warning Signs**: A sudden drop in uptime signals unexpected reboots or failures.
- **Performance Analysis**: Correlating uptime with system load, resource usage, and failures can help in preventive maintenance.
- **SLAs & Compliance**: Ensures businesses meet their uptime guarantees as per service-level agreements.

### **Data Type Decision: INTEGER vs. TIME Data Type**

- **INTEGER**: Chosen for simplicity and ease of calculation (e.g., querying `uptime_in_mins > 1000` is efficient).
- **Alternative: TIME or TIMESTAMP**:
    - While storing the last reboot time (`last_reboot_time TIMESTAMP`) is an alternative, querying uptime would require date-time operations.
    - Calculating uptime dynamically (`NOW() - last_reboot_time`) would be possible but may have performance trade-offs when dealing with large datasets.
- **Final Decision**: `uptime_in_mins` as an `INTEGER` allows for quick, efficient querying while optionally pairing it with `last_reboot_time` for added context.

### **Preventing Infinite Growth of `uptime_in_mins`**

- Without constraints, this value would infinitely increment until a reboot occurs.
- **Solution: Implement a Maximum Threshold**
    - Set a reasonable limit (e.g., `MAX_UPTIME = 525600` minutes, which is 1 year).
    - If a system surpasses this, automatically reset `uptime_in_mins` and log a maintenance event.
    - Can be implemented in SQL with triggers or handled at the application level.

---

### **Tracking Latency (`latency_in_ms` as FLOAT)**

### **Purpose**

- Measures the time taken for a server to respond to requests in milliseconds.
- High latency signals performance bottlenecks and possible degraded user experience.

### **Why Track Latency?**

- **Performance Optimization**: Helps identify slow API responses, network issues, or overloaded servers.
- **Capacity Planning**: Trends in latency can indicate when scaling is needed.
- **SLA Compliance**: Ensures response times remain within contractual obligations.

### **Data Type Decision: FLOAT vs. INTEGER**

- **FLOAT**: Chosen for precision, as latency values often have decimal points (e.g., `3.67 ms`).
- **Alternative: INTEGER**: Less ideal because it would round latency values, reducing accuracy.

### **Handling Anomalous Values**

- Use outlier detection (e.g., flag latency values above a reasonable threshold, such as 1000 ms).
- Store aggregated values (min/max/average latency) for trend analysis.

---

### **Tracking Database Queries Per Second (`db_queries_per_sec` as INTEGER)**

### **Purpose**

- Tracks how many database queries a server processes per second.
- Helps optimize database performance and detect bottlenecks.

### **Why Track Database Queries?**

- **Query Optimization**: Helps database administrators tune slow queries and indexes.
- **Capacity Planning**: Determines whether a database server needs scaling.
- **Anomaly Detection**: Sudden spikes in queries may indicate unexpected traffic or security threats.

### **Data Type Decision: INTEGER vs. FLOAT**

- **INTEGER**: Chosen because query counts are whole numbers.
- **Alternative: FLOAT**: Unnecessary, as queries per second are typically reported as whole numbers.

### **Handling High Query Volumes**

- Implement rolling time windows (e.g., track `db_queries_per_sec` over 5-minute intervals instead of per second).
- Store historical trends to analyze long-term patterns.

---

### **Final Considerations for Data Storage & Optimization**

- **Indexing**: Ensure indexes exist on frequently queried columns to speed up lookups.
- **Aggregation Tables**: Maintain separate tables for historical trends to reduce the load on live metrics.
- **Alerting & Monitoring**: Set up alerts when uptime, latency, or database queries exceed predefined thresholds.

By carefully choosing data types and implementing safeguards, this database provides an efficient and scalable way to track critical server metrics while preventing common pitfalls like infinite growth or performance degradation.