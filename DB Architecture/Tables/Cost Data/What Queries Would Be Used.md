# What Queries Would Be Used?

Find total monthly cost per region:

```sql
sql
CopyEdit
SELECT region, SUM(total_monthly_cost) AS total_cost
FROM cost_data
GROUP BY region;

```

**Why?** This query helps identify which regions have the highest operational costs, allowing for cost optimizations and adjustments in resource distribution.

Find servers with the highest hourly costs:

```sql
sql
CopyEdit
SELECT server_id, cost_per_hour
FROM cost_data
ORDER BY cost_per_hour DESC
LIMIT 10;

```

**Why?** Identifies the most expensive servers, which may indicate inefficient resource allocation, overprovisioning, or high-demand workloads.

Check if a department is exceeding its budget:

```sql
sql
CopyEdit
SELECT team_allocation, SUM(total_monthly_cost) AS total_cost
FROM cost_data
GROUP BY team_allocation
HAVING total_cost > 10000;

```

**Why?** Helps track department-level costs to ensure spending remains within budget.

---

### **Additional Queries for Deeper Analysis**

Find cost trends over time for a specific server:

```sql
sql
CopyEdit
SELECT timestamp::DATE, SUM(cost_per_hour * 24) AS daily_cost
FROM cost_data
WHERE server_id = 'your-server-id'
GROUP BY timestamp::DATE
ORDER BY timestamp::DATE;

```

**Why?** Helps analyze cost fluctuations over time for a given server, identifying trends, spikes, and anomalies.

Compare cost and resource utilization to detect inefficiencies:

```sql
sql
CopyEdit
SELECT c.server_id, c.cost_per_hour, sm.cpu_usage, sm.memory_usage
FROM cost_data c
JOIN server_metrics sm ON c.server_id = sm.server_id
WHERE c.cost_per_hour > 50 AND (sm.cpu_usage < 20 OR sm.memory_usage < 30);

```

**Why?** Finds servers that have high costs but low resource utilization, helping identify wasteful spending.

Identify the most cost-efficient regions:

```sql
sql
CopyEdit
SELECT region, SUM(total_monthly_cost) / COUNT(DISTINCT server_id) AS avg_cost_per_server
FROM cost_data
GROUP BY region
ORDER BY avg_cost_per_server ASC;

```

**Why?** Helps in strategic decision-making by identifying which regions offer the most cost-effective infrastructure.

Forecast next month's cost based on past trends:

```sql
sql
CopyEdit
SELECT region, EXTRACT(MONTH FROM timestamp) AS month, AVG(total_monthly_cost) AS avg_cost
FROM cost_data
WHERE timestamp >= NOW() - INTERVAL '6 months'
GROUP BY region, month
ORDER BY region, month;

```

**Why?** Uses past cost data to estimate future spending, aiding in budgeting and financial planning.

Would you like any specific queries tailored to a particular business case?