# Power BI Connection to PostgreSQL on VM via SSH Tunnel using ODBC

Overview
This guide explains how to connect Power BI Desktop running on your local Windows machine to a PostgreSQL database hosted on a remote VM. The connection is secured via an SSH tunnel forwarding the remote PostgreSQL port to a local port. The connection uses the PostgreSQL ODBC driver because the native Power BI PostgreSQL connector caused SSL certificate errors.

Prerequisites
SSH access to the remote VM with PostgreSQL installed

PostgreSQL running on the VM and listening on port 5432

SSH private key for authentication (cimd_postgresql_key)

Power BI Desktop installed on local machine

PostgreSQL ODBC driver installed on local machine (download from PostgreSQL ODBC Driver)

Step 1: Establish SSH Tunnel
Open a terminal (e.g., PowerShell or CMD) on your local Windows machine and run:

bash
Copy
Edit
ssh -i "C:\Users\burha\.ssh\cimd_postgresql_key" -L 15432:localhost:5432 ubuntu@40.233.74.182
This command forwards your local port 15432 to the remote VM's PostgreSQL port 5432.

Keep this terminal open while using Power BI.

Step 2: Install PostgreSQL ODBC Driver
Download and install the latest PostgreSQL ODBC driver for Windows from:
https://www.postgresql.org/ftp/odbc/versions/msi/

Step 3: Configure ODBC Data Source
Open ODBC Data Source Administrator (64-bit):

Press Win + S, type ODBC, select ODBC Data Sources (64-bit).

Click on System DSN tab.

Click Add... and select PostgreSQL Unicode(x64), then Finish.

Fill in connection details:

Data Source Name: PostgresTunnel (or any meaningful name)

Server: localhost

Port: 15432

Database: postgres

User Name: postgres

Password: (your postgres password)

In the SSL tab (if available), set SSL mode to disable.

Click Test to verify the connection is successful.

Click OK to save the DSN.

Step 4: Connect Power BI via ODBC
Open Power BI Desktop.

Click Get Data > More...

Select ODBC and click Connect.

In the dialog, select the DSN you created (PostgresTunnel) and click OK.

Enter your PostgreSQL username and password if prompted.

Choose your tables or write SQL queries as needed to load data.

Notes
Keep the SSH tunnel terminal open whenever working in Power BI to maintain the connection.

The native Power BI PostgreSQL connector had issues with SSL certificate validation through the tunnel, hence using ODBC with SSL disabled resolved these errors.

You can create multiple ODBC DSNs for different databases or ports as needed.

## Designing Power BI Dashboards from a PostgreSQL Database: Process & Best Practices

This section explains the recommended workflow for building insightful dashboards in Power BI using data from a PostgreSQL database. It covers how to decide what to visualize, how to prepare the data for each visual, and how to automate the process using Power Query M scripts and DAX formulas.

---

### 1. **Decide What to Visualize (Dashboard Planning)**

Before building visuals, determine what business questions or KPIs you want to answer. Example ideas based on a cloud infrastructure monitoring database:

- **Server Health Trends:** Track CPU, memory, disk, and network usage over time.
- **Application Distribution:** See how applications are deployed (e.g., containerized, VM, serverless).
- **Error & Incident Monitoring:** Identify servers or regions with the most errors/incidents.
- **Cost Analysis:** Monitor monthly costs by team, server, or application.
- **Team Performance:** Analyze team member roles, incident response times, and workload.
- **Downtime & SLA Tracking:** Visualize planned vs. unplanned downtime and SLA compliance.
- **Alerting & Severity:** Track alert frequency and severity over time.
- **Geographical Distribution:** Map servers, applications, or incidents by location.

---

### 2. **Identify Required Tables and Data Transformations**

For each visual, list the tables and fields needed. Most visuals require data to be joined, grouped, or aggregated.  
**Example:**

- _Server Health Trend_: Needs `server_metrics` (for metrics) and `location` (for server names/regions).
- _Monthly Cost by Team_: Needs `cost_data` and `team_management`.

---

### 3. **Prepare Data Using Power Query (M Scripts)**

For each visual, create a Power Query (M) script to:

- Load the required tables.
- Join tables as needed (e.g., metrics with location).
- Filter, group, and aggregate data (e.g., average CPU per day).
- Output a clean, ready-to-use table for the visual.

**Example M Script for Daily Server Health:**

```m
let
    server_metrics = Odbc.Query("dsn=PostgresTunnel", "SELECT * FROM server_metrics"),
    location = Odbc.Query("dsn=PostgresTunnel", "SELECT * FROM location"),
    merged = Table.NestedJoin(server_metrics, {"location_id"}, location, {"location_id"}, "location", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "location", {"location_name"}),
    addedDay = Table.AddColumn(expanded, "day", each Date.From([timestamp])),
    grouped = Table.Group(
        addedDay,
        {"server_id", "location_name", "day"},
        {
            {"avg_cpu", each List.Average([cpu_usage]), type number},
            {"avg_memory", each List.Average([memory_usage]), type number}
        }
    )
in
    grouped
```

GitHub Copilot 4. Create Calculated Columns, Measures, or Tables Using DAX
After loading and transforming data, use DAX to:

Create calculated columns (e.g., cost per user).
Define measures (e.g., total errors, average response time).
Build calculated tables for advanced aggregations.
Example DAX Measure:

5. Build Visuals in Power BI
   Use the transformed tables and DAX measures to create charts, graphs, maps, and dashboards.
   Examples: Line chart for CPU trends, pie chart for app distribution, bar chart for error counts, map for server locations.
6. Document Each Visual
   For maintainability, document:

The business question/KPI.
The tables and fields used.
The M script for data transformation.
The DAX formulas used.
The type of visual and its purpose. 7. Summary Workflow
Define Visual/KPI →
Identify Tables/Fields →
Write M Script for Transformation →
Write DAX for Calculations →
Build Visual in Power BI →
Document the Process 8. Best Practices
Only load and transform the data you need for each visual.
Keep M scripts and DAX formulas well-commented.
Save and share your Power BI file as a template for reuse.
Regularly update documentation as visuals and requirements evolve.

---

<!--
Prompt 1: I will now proivde you with the DDL again, based off the DDL, please create 10 highly important (and what employers really care about and will be impressed that i have a visual for) business question/KPIs: [INSERT FULL DDL]

Prompt 2: For the selected question/KPI below, write the M script required (identify the tables and fileds for this), and then write the DAX for caluclations.
-->

## Top 10 Business Questions / KPIs for Cloud Infrastructure Monitoring (Power BI)

Below are ten high-impact business questions and KPIs, with the required tables/fields, M scripts, DAX measures, and visualization steps. These are designed to impress employers and provide actionable insights.

---

### 1. **Server Health & Resource Utilization Trends**

**Question:** How are CPU, memory, disk, and network usage trending across all servers over time?

- **Tables:** `server_metrics`, `location`
- **Why it matters:** Proactive capacity planning, performance bottleneck detection, and infrastructure scaling.

#### Tables and Fields Needed

- **server_metrics:**
  - server_id
  - location_id
  - timestamp
  - cpu_usage
  - memory_usage
  - disk_usage_percent
  - network_in_bytes
  - network_out_bytes
- **location:**
  - location_id
  - location_name

#### M Script

```m
let
    server_metrics = Odbc.Query("dsn=PostgresTunnel", "
        SELECT server_id, location_id, timestamp, cpu_usage, memory_usage, disk_usage_percent, network_in_bytes, network_out_bytes
        FROM server_metrics
    "),
    location = Odbc.Query("dsn=PostgresTunnel", "
        SELECT location_id, location_name
        FROM location
    "),
    merged = Table.NestedJoin(server_metrics, {"location_id"}, location, {"location_id"}, "location", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "location", {"location_name"}),
    addedDay = Table.AddColumn(expanded, "day", each Date.From([timestamp])),
    grouped = Table.Group(
        addedDay,
        {"server_id", "location_name", "day"},
        {
            {"avg_cpu", each List.Average([cpu_usage]), type number},
            {"avg_memory", each List.Average([memory_usage]), type number},
            {"avg_disk_usage", each List.Average([disk_usage_percent]), type number},
            {"avg_network_in", each List.Average([network_in_bytes]), type number},
            {"avg_network_out", each List.Average([network_out_bytes]), type number}
        }
    )
in
    grouped
```

#### DAX

```dax
Avg CPU Usage = AVERAGE(ServerHealthTrends[avg_cpu])
Peak CPU Usage = MAX(ServerHealthTrends[avg_cpu])
Avg Memory Usage = AVERAGE(ServerHealthTrends[avg_memory])
High CPU Days = CALCULATE(COUNTROWS(ServerHealthTrends), ServerHealthTrends[avg_cpu] > 80)
Total Network Throughput = SUM(ServerHealthTrends[avg_network_in]) + SUM(ServerHealthTrends[avg_network_out])
```

#### Visualization Steps

1. Line chart: `day` (X), `avg_cpu` (Y), legend: `server_id`
2. Line chart: `day` (X), `avg_memory` (Y), legend: `server_id`
3. Line chart: `day` (X), `avg_disk_usage` (Y), legend: `server_id`
4. Line chart: `day` (X), `avg_network_in`/`avg_network_out` (Y), legend: `server_id`
5. KPI cards: `Avg CPU Usage`, `Peak CPU Usage`, `High CPU Days`, `Total Network Throughput`

---

### 2. **Application Deployment by Hosting Environment**

**Question:** What is the distribution of applications across different hosting environments?

- **Tables:** `applications`
- **Why it matters:** Shows modernization progress, cloud adoption, and risk areas.

#### Tables and Fields Needed

- **applications:**
  - app_id
  - app_name
  - app_type
  - hosting_environment

#### M Script

```m
let
    applications = Odbc.Query("dsn=PostgresTunnel", "
        SELECT app_id, app_name, app_type, hosting_environment
        FROM applications
    "),
    grouped = Table.Group(
        applications,
        {"hosting_environment"},
        {{"app_count", each Table.RowCount(_), Int64.Type}}
    )
in
    grouped
```

#### DAX

```dax
Total Applications = COUNT(applications[app_id])
Apps by Environment = CALCULATE(COUNT(applications[app_id]), ALLEXCEPT(applications, applications[hosting_environment]))
Percent Containerized = DIVIDE(CALCULATE(COUNTROWS(FILTER(applications, applications[hosting_environment] = "Containerized"))), [Total Applications], 0)
Unique App Types = DISTINCTCOUNT(applications[app_type])
Unknown Hosting Apps = CALCULATE(COUNTROWS(applications), applications[hosting_environment] = "Unknown")
```

#### Visualization Steps

1. Pie chart: `app_count` by `hosting_environment`
2. Bar chart: `app_count` by `hosting_environment`
3. Card: `Percent Containerized`
4. Card: `Unique App Types`
5. Card: `Unknown Hosting Apps`

---

### 3. **Incident Response Effectiveness**

**Question:** What is the average incident resolution time by team and priority level?

- **Tables:** `incident_response_logs`, `team_management`
- **Why it matters:** Measures team performance, identifies bottlenecks, and supports SLA compliance.

#### Tables and Fields Needed

- **incident_response_logs:**
  - incident_id
  - response_team_id
  - priority_level
  - resolution_time_minutes
  - status
- **team_management:**
  - team_id
  - team_name

#### M Script

```m
let
    incidents = Odbc.Query("dsn=PostgresTunnel", "
        SELECT incident_id, response_team_id, priority_level, resolution_time_minutes, status
        FROM incident_response_logs
    "),
    teams = Odbc.Query("dsn=PostgresTunnel", "
        SELECT team_id, team_name
        FROM team_management
    "),
    merged = Table.NestedJoin(incidents, {"response_team_id"}, teams, {"team_id"}, "team", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "team", {"team_name"})
in
    expanded
```

#### DAX

```dax
Avg Resolution Time = AVERAGE(incident_response_logs[resolution_time_minutes])
Incidents Within SLA = CALCULATE(COUNTROWS(incident_response_logs), incident_response_logs[resolution_time_minutes] <= 60)
Open Incidents = CALCULATE(COUNTROWS(incident_response_logs), incident_response_logs[status] <> "Resolved")
Critical Incidents = CALCULATE(COUNTROWS(incident_response_logs), incident_response_logs[priority_level] = "Critical")
Avg Resolution By Team = CALCULATE(AVERAGE(incident_response_logs[resolution_time_minutes]), ALLEXCEPT(incident_response_logs, incident_response_logs[response_team_id]))
```

#### Visualization Steps

1. Clustered bar chart: `Avg Resolution Time` by `team_name` and `priority_level`
2. Card: `Incidents Within SLA`
3. Card: `Open Incidents`
4. Card: `Critical Incidents`
5. Table: `Avg Resolution By Team`

---

### 4. **Monthly Infrastructure Cost by Team**

**Question:** How much is each team spending on infrastructure monthly, and how is this trending?

- **Tables:** `cost_data`, `team_management`
- **Why it matters:** Enables cost optimization, budget tracking, and accountability.

#### Tables and Fields Needed

- **cost_data:**
  - server_id
  - team_allocation
  - timestamp
  - total_monthly_cost
- **team_management:**
  - team_id
  - team_name

#### M Script

```m
let
    cost_data = Odbc.Query("dsn=PostgresTunnel", "
        SELECT server_id, team_allocation, timestamp, total_monthly_cost
        FROM cost_data
    "),
    teams = Odbc.Query("dsn=PostgresTunnel", "
        SELECT team_id, team_name
        FROM team_management
    "),
    merged = Table.NestedJoin(cost_data, {"team_allocation"}, teams, {"team_id"}, "team", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "team", {"team_name"}),
    addedMonth = Table.AddColumn(expanded, "month", each Date.Month([timestamp]))
in
    addedMonth
```

#### DAX

```dax
Total Monthly Cost = SUM(cost_data[total_monthly_cost])
Avg Monthly Cost Per Team = AVERAGEX(VALUES(cost_data[team_allocation]), [Total Monthly Cost])
Teams Over 10k = CALCULATE(DISTINCTCOUNT(cost_data[team_allocation]), [Total Monthly Cost] > 10000)
Cost Trend = [Total Monthly Cost] - CALCULATE([Total Monthly Cost], DATEADD(cost_data[timestamp], -1, MONTH))
Highest Cost Team = TOPN(1, SUMMARIZE(cost_data, cost_data[team_allocation], "Cost", [Total Monthly Cost]), [Total Monthly Cost], DESC)
```

#### Visualization Steps

1. Stacked column chart: `Total Monthly Cost` by `month` and `team_name`
2. Line chart: `Cost Trend` by `month`
3. Card: `Avg Monthly Cost Per Team`
4. Card: `Teams Over 10k`
5. Table: `Highest Cost Team`

---

### 5. **Error & Alert Hotspots**

**Question:** Which servers or applications generate the most errors and critical alerts?

- **Tables:** `error_logs`, `alert_history`, `applications`
- **Why it matters:** Focuses remediation efforts and improves reliability.

#### Tables and Fields Needed

- **error_logs:**
  - error_id
  - server_id
  - app_id
  - timestamp
- **alert_history:**
  - alert_id
  - server_id
  - alert_severity
  - timestamp
- **applications:**
  - app_id
  - app_name

#### M Script

```m
let
    error_logs = Odbc.Query("dsn=PostgresTunnel", "
        SELECT error_id, server_id, app_id, timestamp
        FROM error_logs
    "),
    alert_history = Odbc.Query("dsn=PostgresTunnel", "
        SELECT alert_id, server_id, alert_severity, timestamp
        FROM alert_history
    "),
    applications = Odbc.Query("dsn=PostgresTunnel", "
        SELECT app_id, app_name
        FROM applications
    ")
in
    error_logs
```

#### DAX

```dax
Total Errors = COUNT(error_logs[error_id])
Critical Alerts = COUNTROWS(FILTER(alert_history, alert_history[alert_severity] = "CRITICAL"))
Servers Over 10 Errors = CALCULATE(DISTINCTCOUNT(error_logs[server_id]), error_logs[timestamp] >= TODAY()-7 && error_logs[error_id] > 10)
Apps Most Alerts = TOPN(1, SUMMARIZE(alert_history, alert_history[server_id], "AlertCount", COUNT(alert_history[alert_id])), [AlertCount], DESC)
Avg Error Rate = AVERAGE(alert_history[alert_severity])
```

#### Visualization Steps

1. Table: `Total Errors` and `Critical Alerts` by `server_id` and `app_id`
2. Bar chart: `Total Errors` by `server_id`
3. Card: `Servers Over 10 Errors`
4. Card: `Apps Most Alerts`
5. Card: `Avg Error Rate`

---

### 6. **Downtime Analysis & SLA Tracking**

**Question:** What is the total planned vs. unplanned downtime, and are we meeting our SLAs?

- **Tables:** `downtime_logs`
- **Why it matters:** Directly impacts customer satisfaction and contractual obligations.

#### Tables and Fields Needed

- **downtime_logs:**
  - downtime_id
  - server_id
  - start_time
  - end_time
  - downtime_duration_minutes
  - is_planned

#### M Script

```m
let
    downtime_logs = Odbc.Query("dsn=PostgresTunnel", "
        SELECT downtime_id, server_id, start_time, end_time, downtime_duration_minutes, is_planned
        FROM downtime_logs
    ")
in
    downtime_logs
```

#### DAX

```dax
Total Downtime Minutes = SUM(downtime_logs[downtime_duration_minutes])
Planned Downtime = CALCULATE(SUM(downtime_logs[downtime_duration_minutes]), downtime_logs[is_planned] = TRUE())
Unplanned Downtime = CALCULATE(SUM(downtime_logs[downtime_duration_minutes]), downtime_logs[is_planned] = FALSE())
Downtime Incidents = COUNT(downtime_logs[downtime_id])
SLA Breaches = CALCULATE(COUNTROWS(downtime_logs), downtime_logs[downtime_duration_minutes] > 60)
```

#### Visualization Steps

1. Stacked column chart: `Planned Downtime` vs `Unplanned Downtime` by `server_id`
2. Card: `Total Downtime Minutes`
3. Card: `Downtime Incidents`
4. Card: `SLA Breaches`
5. Line chart: Downtime trend over time

---

### 7. **Team Member Role Distribution & Coverage**

**Question:** What is the distribution of team member roles, and are there gaps in critical skill areas?

- **Tables:** `team_members`, `team_management`
- **Why it matters:** Ensures adequate coverage for operations, security, and support.

#### Tables and Fields Needed

- **team_members:**
  - member_id
  - team_id
  - role
- **team_management:**
  - team_id
  - team_name

#### M Script

```m
let
    team_members = Odbc.Query("dsn=PostgresTunnel", "
        SELECT member_id, team_id, role
        FROM team_members
    "),
    teams = Odbc.Query("dsn=PostgresTunnel", "
        SELECT team_id, team_name
        FROM team_management
    "),
    merged = Table.NestedJoin(team_members, {"team_id"}, teams, {"team_id"}, "team", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "team", {"team_name"})
in
    expanded
```

#### DAX

```dax
Total Team Members = COUNT(team_members[member_id])
Unique Roles = DISTINCTCOUNT(team_members[role])
Members Per Role = CALCULATE(COUNT(team_members[member_id]), ALLEXCEPT(team_members, team_members[role]))
Small Teams = CALCULATE(DISTINCTCOUNT(team_members[team_id]), CALCULATE(COUNT(team_members[member_id]), ALLEXCEPT(team_members, team_members[team_id])) < 3)
Members Multiple Roles = CALCULATE(DISTINCTCOUNT(team_members[member_id]), CALCULATE(DISTINCTCOUNT(team_members[role]), ALLEXCEPT(team_members, team_members[member_id])) > 1)
```

#### Visualization Steps

1. Pie chart: `Members Per Role`
2. Bar chart: `Total Team Members` by `team_name`
3. Card: `Unique Roles`
4. Card: `Small Teams`
5. Card: `Members Multiple Roles`

---

### 8. **Geographical Distribution of Assets**

**Question:** Where are our servers, applications, and incidents geographically located?

- **Tables:** `location`, `server_metrics`, `applications`, `incident_response_logs`
- **Why it matters:** Supports disaster recovery planning, compliance, and regional performance analysis.

#### Tables and Fields Needed

- **location:**
  - location_id
  - location_name
  - country
  - region
- **server_metrics:**
  - server_id
  - location_id
- **applications:**
  - app_id
  - app_name
- **incident_response_logs:**
  - incident_id
  - server_id

#### M Script

```m
let
    location = Odbc.Query("dsn=PostgresTunnel", "
        SELECT location_id, location_name, country, region
        FROM location
    "),
    server_metrics = Odbc.Query("dsn=PostgresTunnel", "
        SELECT server_id, location_id
        FROM server_metrics
    "),
    applications = Odbc.Query("dsn=PostgresTunnel", "
        SELECT app_id, app_name
        FROM applications
    "),
    incidents = Odbc.Query("dsn=PostgresTunnel", "
        SELECT incident_id, server_id
        FROM incident_response_logs
    ")
in
    location
```

#### DAX

```dax
Total Locations = COUNT(location[location_id])
Servers Per Region = CALCULATE(COUNT(server_metrics[server_id]), ALLEXCEPT(location, location[region]))
Applications Per Country = CALCULATE(COUNT(applications[app_id]), ALLEXCEPT(location, location[country]))
Incidents Per Location = CALCULATE(COUNT(incident_response_logs[incident_id]), ALLEXCEPT(location, location[location_id]))
Locations Over 5 Incidents = CALCULATE(DISTINCTCOUNT(location[location_id]), [Incidents Per Location] > 5)
```

#### Visualization Steps

1. Map: `location_name` (location), `Total Locations` (size)
2. Bar chart: `Servers Per Region` by `region`
3. Bar chart: `Applications Per Country` by `country`
4. Table: `Incidents Per Location`
5. Card: `Locations Over 5 Incidents`

---

### 9. **Resource Allocation Efficiency**

**Question:** How efficiently are resources (CPU, memory, disk) being allocated and utilized per application?

- **Tables:** `resource_allocation`, `applications`, `server_metrics`
- **Why it matters:** Identifies over/under-provisioning and supports cost savings.

#### Tables and Fields Needed

- **resource_allocation:**
  - server_id
  - app_id
  - allocated_memory
  - allocated_cpu
  - allocated_disk_space
  - actual_memory_usage
  - actual_cpu_usage
  - actual_disk_usage
- **applications:**
  - app_id
  - app_name
- **server_metrics:**
  - server_id

#### M Script

```m
let
    resource_allocation = Odbc.Query("dsn=PostgresTunnel", "
        SELECT server_id, app_id, allocated_memory, allocated_cpu, allocated_disk_space, actual_memory_usage, actual_cpu_usage, actual_disk_usage
        FROM resource_allocation
    "),
    applications = Odbc.Query("dsn=PostgresTunnel", "
        SELECT app_id, app_name
        FROM applications
    "),
    merged = Table.NestedJoin(resource_allocation, {"app_id"}, applications, {"app_id"}, "app", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "app", {"app_name"}),
    cpu_efficiency = Table.AddColumn(expanded, "cpu_efficiency", each [actual_cpu_usage] / [allocated_cpu]),
    memory_efficiency = Table.AddColumn(cpu_efficiency, "memory_efficiency", each [actual_memory_usage] / [allocated_memory]),
    disk_efficiency = Table.AddColumn(memory_efficiency, "disk_efficiency", each [actual_disk_usage] / [allocated_disk_space])
in
    disk_efficiency
```

#### DAX

```dax
Avg CPU Efficiency = AVERAGE(resource_allocation[cpu_efficiency])
Avg Memory Efficiency = AVERAGE(resource_allocation[memory_efficiency])
Avg Disk Efficiency = AVERAGE(resource_allocation[disk_efficiency])
Apps Low CPU Efficiency = CALCULATE(DISTINCTCOUNT(resource_allocation[app_id]), resource_allocation[cpu_efficiency] < 0.5)
Servers Over Memory = CALCULATE(DISTINCTCOUNT(resource_allocation[server_id]), resource_allocation[memory_efficiency] > 1)
```

#### Visualization Steps

1. Table: `cpu_efficiency`, `memory_efficiency`, `disk_efficiency` by `app_name`
2. Bar chart: `Avg CPU Efficiency`, `Avg Memory Efficiency`, `Avg Disk Efficiency`
3. Card: `Apps Low CPU Efficiency`
4. Card: `Servers Over Memory`

---

### 10. **User Access & Security Monitoring**

**Question:** What are the patterns of user access (read/write/delete/execute) across servers, and are there any anomalies?

- **Tables:** `user_access_logs`, `users`
- **Why it matters:** Supports security audits, compliance, and insider threat detection.

#### Tables and Fields Needed

- **user_access_logs:**
  - access_id
  - user_id
  - server_id
  - access_type
  - timestamp
- **users:**
  - user_id
  - username

#### M Script

```m
let
    user_access_logs = Odbc.Query("dsn=PostgresTunnel", "
        SELECT access_id, user_id, server_id, access_type, timestamp
        FROM user_access_logs
    "),
    users = Odbc.Query("dsn=PostgresTunnel", "
        SELECT user_id, username
        FROM users
    "),
    merged = Table.NestedJoin(user_access_logs, {"user_id"}, users, {"user_id"}, "user", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(merged, "user", {"username"})
in
    expanded
```

#### DAX

```dax
Total Access Logs = COUNT(user_access_logs[access_id])
Read Accesses = COUNTROWS(FILTER(user_access_logs, user_access_logs[access_type] = "READ"))
Write Accesses = COUNTROWS(FILTER(user_access_logs, user_access_logs[access_type] = "WRITE"))
Unique Users = DISTINCTCOUNT(user_access_logs[user_id])
Active Users Last 7 Days = CALCULATE(DISTINCTCOUNT(user_access_logs[user_id]), user_access_logs[timestamp] >= TODAY()-7 && user_access_logs[access_id] > 10)
```

#### Visualization Steps

1. Table: `access_id`, `access_type`, `username`, `server_id`
2. Bar chart: `Read Accesses`, `Write Accesses` by `access_type`
3. Card: `Total Access Logs`
4. Card: `Unique Users`
5. Card: `Active Users Last 7 Days`

---
