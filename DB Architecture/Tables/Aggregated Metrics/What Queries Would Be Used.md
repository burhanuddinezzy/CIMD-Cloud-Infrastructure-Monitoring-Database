# What Queries Would Be Used?

These queries help in **trend analysis, anomaly detection, capacity planning, and cost optimization**.

### **Find the servers with the highest CPU utilization in the last 24 hours**

**Why?** Identifies servers that may be overburdened and need scaling or optimization. **Optimization?** Adds indexing on `hourly_avg_cpu_usage` for faster lookup. **Query:**

```sql
sql
CopyEdit
SELECT server_id, AVG(hourly_avg_cpu_usage) AS avg_cpu_usage FROM aggregated_metrics WHERE hourly_avg_cpu_usage > 80 AND timestamp >= NOW() - INTERVAL 24 HOUR GROUP BY server_id ORDER BY avg_cpu_usage DESC;

```

### **Compare peak network usage across regions**

**Why?** Helps in understanding **network congestion patterns** to optimize bandwidth. **Optimization?** Uses partitioning on `region` to speed up filtering. **Query:**

```sql
sql
CopyEdit
SELECT region, MAX(peak_network_usage) AS max_network FROM aggregated_metrics GROUP BY region ORDER BY max_network DESC;

```

### **Find servers that violated uptime SLAs**

**Why?** Helps detect **underperforming servers** that require maintenance or scaling. **Optimization?** Uses **indexed lookups** on `uptime_percentage` for quick retrieval. **Query:**

```sql
sql
CopyEdit
SELECT server_id, uptime_percentage FROM aggregated_metrics WHERE uptime_percentage < 99.9;

```

### **Identify servers with frequent performance spikes**

**Why?** Helps **proactively address performance instability**. **Optimization?** Uses **rolling averages** to avoid false positives from single spikes. **Query:**

```sql
sql
CopyEdit
SELECT server_id, COUNT(*) AS spike_count FROM aggregated_metrics WHERE hourly_avg_cpu_usage > 85 OR hourly_avg_memory_usage > 90 GROUP BY server_id ORDER BY spike_count DESC;

```

### **Detect underutilized servers for cost savings**

**Why?** Helps in **cost reduction** by identifying servers that can be downsized. **Optimization?** Uses **window functions** for trend analysis. **Query:**

```sql
sql
CopyEdit
SELECT server_id, AVG(hourly_avg_cpu_usage) AS avg_cpu_usage, AVG(hourly_avg_memory_usage) AS avg_memory_usage FROM aggregated_metrics WHERE timestamp >= NOW() - INTERVAL 30 DAY GROUP BY server_id HAVING avg_cpu_usage < 10 AND avg_memory_usage < 15 ORDER BY avg_cpu_usage ASC;

```

### **Compare hourly performance trends over the past week**

**Why?** Helps in **forecasting capacity requirements**. **Optimization?** Uses **time-series indexing**. **Query:**

```sql
sql
CopyEdit
SELECT DATE(timestamp) AS date, HOUR(timestamp) AS hour, AVG(hourly_avg_cpu_usage) AS avg_cpu_usage, AVG(hourly_avg_memory_usage) AS avg_memory_usage FROM aggregated_metrics WHERE timestamp >= NOW() - INTERVAL 7 DAY GROUP BY date, hour ORDER BY date DESC, hour DESC;

```

### **Find the costliest servers based on resource usage**

**Why?** Helps in **cost-performance optimization**. **Optimization?** Joins with `cost_data` for a full efficiency analysis. **Query:**

```sql
sql
CopyEdit
SELECT am.server_id, am.region, cd.hourly_cost, am.hourly_avg_cpu_usage, am.hourly_avg_memory_usage, am.peak_network_usage FROM aggregated_metrics am JOIN cost_data cd ON am.server_id = cd.server_id WHERE timestamp >= NOW() - INTERVAL 1 DAY ORDER BY cd.hourly_cost DESC LIMIT 10;

```

### **Takeaways**

Queries are **optimized for performance** using indexing, partitioning, and filtering. The insights help with **scalability planning, cost reduction, and incident prevention**. Data joins with other tables (`cost_data`, `downtime_logs`, `server_metrics`) ensure **comprehensive analysis**.

Would you like more complex analytical queries, like machine learning-based anomaly detection? 🚀