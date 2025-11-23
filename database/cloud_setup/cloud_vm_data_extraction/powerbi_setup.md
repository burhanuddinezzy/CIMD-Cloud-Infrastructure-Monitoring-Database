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

**Rename table to:** `ServerHealthTrends`

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
    ServerHealthTrends = Odbc.Query("dsn=PostgresTunnel", "
        SELECT server_id, location_id, timestamp, cpu_usage, memory_usage, disk_usage_percent, network_in_bytes, network_out_bytes
        FROM server_metrics
    ")
in
    ServerHealthTrends
```

#### DAX

```dax
Avg CPU Usage = AVERAGE(ServerHealthTrends[cpu_usage])
Peak CPU Usage = MAX(ServerHealthTrends[cpu_usage])
Avg Memory Usage = AVERAGE(ServerHealthTrends[memory_usage])
High CPU Days = CALCULATE(COUNTROWS(ServerHealthTrends), ServerHealthTrends[cpu_usage] > 80)
Total Network Throughput = SUM(ServerHealthTrends[network_in_bytes]) + SUM(ServerHealthTrends[network_out_bytes])
```

#### Visualization Steps

1. Line chart: `day` (X), `avg_cpu` (Y), legend: `server_id`
2. Line chart: `day` (X), `avg_memory` (Y), legend: `server_id`
3. Line chart: `day` (X), `avg_disk_usage` (Y), legend: `server_id`
4. Line chart: `day` (X), `avg_network_in`/`avg_network_out` (Y), legend: `server_id`
5. KPI cards: `Avg CPU Usage`, `Peak CPU Usage`, `High CPU Days`, `Total Network Throughput`

---

### 2. **Application Deployment by Hosting Environment**

**Rename table to:** `ApplicationsByHostingEnv`

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
    ApplicationsByHostingEnv = Odbc.Query("dsn=PostgresTunnel", "
        SELECT app_id, app_name, app_type, hosting_environment
        FROM applications
    ")
in
    ApplicationsByHostingEnv
```

#### DAX

```dax
Total Applications = COUNT(ApplicationsByHostingEnv[app_id])
Apps by Environment = CALCULATE(COUNT(ApplicationsByHostingEnv[app_id]), ALLEXCEPT(ApplicationsByHostingEnv, ApplicationsByHostingEnv[hosting_environment]))
Percent Containerized = DIVIDE(
    CALCULATE(COUNTROWS(FILTER(ApplicationsByHostingEnv, ApplicationsByHostingEnv[hosting_environment] = "Containerized"))),
    [Total Applications], 0
)
Unique App Types = DISTINCTCOUNT(ApplicationsByHostingEnv[app_type])
Unknown Hosting Apps = CALCULATE(COUNTROWS(ApplicationsByHostingEnv), ApplicationsByHostingEnv[hosting_environment] = "Unknown")
```

#### Visualization Steps

1. Pie chart: `app_count` by `hosting_environment`
2. Bar chart: `app_count` by `hosting_environment`
3. Card: `Percent Containerized`
4. Card: `Unique App Types`
5. Card: `Unknown Hosting Apps`

---

### 3. **Incident Response Effectiveness**

**Rename table to:** `IncidentResponseByTeam`

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
    IncidentResponseByTeam = Odbc.Query("dsn=PostgresTunnel", "
        SELECT ir.incident_id, ir.response_team_id, ir.priority_level, ir.resolution_time_minutes, ir.status, tm.team_name
        FROM incident_response_logs ir
        LEFT JOIN team_management tm ON ir.response_team_id = tm.team_id
    ")
in
    IncidentResponseByTeam
```

#### DAX

```dax
Avg Resolution Time = AVERAGE(IncidentResponseByTeam[resolution_time_minutes])
Incidents Within SLA = CALCULATE(COUNTROWS(IncidentResponseByTeam), IncidentResponseByTeam[resolution_time_minutes] <= 60)
Open Incidents = CALCULATE(COUNTROWS(IncidentResponseByTeam), IncidentResponseByTeam[status] <> "Resolved")
Critical Incidents = CALCULATE(COUNTROWS(IncidentResponseByTeam), IncidentResponseByTeam[priority_level] = "Critical")
Avg Resolution By Team = AVERAGE(IncidentResponseByTeam[resolution_time_minutes])
```

#### Visualization Steps

1. Clustered bar chart: `Avg Resolution Time` by `team_name` and `priority_level`
2. Card: `Incidents Within SLA`
3. Card: `Open Incidents`
4. Card: `Critical Incidents`
5. Table: `Avg Resolution By Team`

---
### 4. **Monthly Infrastructure Cost by Team**

**Rename table to:** `MonthlyCostByTeam`

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
    MonthlyCostByTeam = Odbc.Query("dsn=PostgresTunnel", "
        SELECT cd.server_id, cd.team_allocation, cd.timestamp, cd.total_monthly_cost, tm.team_name
        FROM cost_data cd
        LEFT JOIN team_management tm ON cd.team_allocation = tm.team_id
    ")
in
    MonthlyCostByTeam
```

#### DAX

```dax
Total Monthly Cost = SUM(MonthlyCostByTeam[total_monthly_cost])
Avg Monthly Cost Per Team = AVERAGEX(VALUES(MonthlyCostByTeam[team_allocation]), [Total Monthly Cost])
Teams Over 10k =
CALCULATE(
    DISTINCTCOUNT(MonthlyCostByTeam[team_allocation]),
    FILTER(
        VALUES(MonthlyCostByTeam[team_allocation]),
        CALCULATE(SUM(MonthlyCostByTeam[total_monthly_cost])) > 10000
    )
)
    For the cost trend dax:
    Create a separate Date table and relate it to your fact table.

    Step 1: Create a Date Table
    In Power BI, go to "Modeling" > "New Table" and enter:
    DateTable = CALENDAR(MIN(MonthlyCostByTeam[timestamp]), MAX(MonthlyCostByTeam[timestamp]))

    Step 2: Create a Month Column in Both Tables
    In DateTable:
    Month = FORMAT(DateTable[Date], "YYYY-MM")

    In MonthlyCostByTeam:
    Month = FORMAT(MonthlyCostByTeam[timestamp], "YYYY-MM")

    Step 3: Create a Relationship
    Relate MonthlyCostByTeam[Month] to DateTable[Month].
    In the model view, relate MonthlyCostByTeam[Month] to DateTable[Month].



    Step 4: Rewrite Your Measure
    Now, use the date column from the Date table in your measure:


Cost Trend =
VAR CurrentMonth = SELECTEDVALUE(DateTable[Month])
RETURN
    [Total Monthly Cost] - CALCULATE([Total Monthly Cost], DATEADD(DateTable[Date], -1, MONTH))


Highest Cost Team Value =
VAR TopTeam =
    TOPN(
        1,
        SUMMARIZE(
            MonthlyCostByTeam,
            MonthlyCostByTeam[team_name],
            "TotalCost", SUM(MonthlyCostByTeam[total_monthly_cost])
        ),
        [TotalCost], DESC
    )
RETURN
    MAXX(TopTeam, [TotalCost])

Highest Cost Team Name =
VAR TopTeam =
    TOPN(
        1,
        SUMMARIZE(
            MonthlyCostByTeam,
            MonthlyCostByTeam[team_name],
            "TotalCost", SUM(MonthlyCostByTeam[total_monthly_cost])
        ),
        [TotalCost], DESC
    )
RETURN
    SELECTCOLUMNS(TopTeam, "team_name", MonthlyCostByTeam[team_name])
```

#### Visualization Steps

1. Stacked column chart: `Total Monthly Cost` by `month` and `team_name`
2. Line chart: `Cost Trend` by `month`
3. Card: `Avg Monthly Cost Per Team`
4. Card: `Teams Over 10k`
5. Table: `Highest Cost Team`

---

### 5. **Error & Alert Hotspots**

**Rename table to:** `ErrorAndAlertHotspots`

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
    ErrorAndAlertHotspots = Odbc.Query("dsn=PostgresTunnel", "
        SELECT el.error_id, el.server_id, el.timestamp, ah.alert_id, ah.alert_severity, ah.timestamp as alert_timestamp
        FROM error_logs el
        LEFT JOIN alert_history ah ON el.server_id = ah.server_id
    ")
in
    ErrorAndAlertHotspots
```

#### DAX

```dax
Total Errors = COUNT(ErrorAndAlertHotspots[error_id])
Critical Alerts = COUNTROWS(FILTER(ErrorAndAlertHotspots, ErrorAndAlertHotspots[alert_severity] = "CRITICAL"))
Servers Over 10 Errors =
CALCULATE(
    COUNTROWS(
        FILTER(
            SUMMARIZE(
                ErrorAndAlertHotspots,
                ErrorAndAlertHotspots[server_id],
                "ErrorCount", COUNTROWS(ErrorAndAlertHotspots)
            ),
            [ErrorCount] > 10
        )
    )
)
Server Most Alerts =
VAR TopServer =
    TOPN(
        1,
        SUMMARIZE(
            ErrorAndAlertHotspots,
            ErrorAndAlertHotspots[server_id],
            "AlertCount", COUNT(ErrorAndAlertHotspots[alert_id])
        ),
        [AlertCount], DESC
    )
RETURN
    MAXX(TopServer, [server_id])
    
Avg Error Rate =
AVERAGEX(
    VALUES(ErrorAndAlertHotspots[server_id]),
    CALCULATE(COUNTROWS(ErrorAndAlertHotspots))
)
```

#### Visualization Steps

1. Table: `Total Errors` and `Critical Alerts` by `server_id`
2. Bar chart: `Total Errors` by `server_id`
3. Card: `Servers Over 10 Errors`
4. Card: `Servers Most Alerts`
5. Card: `Avg Error Rate`

---

### 6. **Downtime Analysis & SLA Tracking**

**Rename table to:** `DowntimeAndSLA`

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
    DowntimeAndSLA = Odbc.Query("dsn=PostgresTunnel", "
        SELECT downtime_id, server_id, start_time, end_time, downtime_duration_minutes, is_planned
        FROM downtime_logs
    ")
in
    DowntimeAndSLA
```

#### DAX

```dax
Total Downtime Minutes = SUM(DowntimeAndSLA[downtime_duration_minutes])
Planned Downtime =
CALCULATE(
    SUM(DowntimeAndSLA[downtime_duration_minutes]),
    VALUE(DowntimeAndSLA[is_planned]) = 1
)
Unplanned Downtime = CALCULATE(SUM(DowntimeAndSLA[downtime_duration_minutes]), DowntimeAndSLA[is_planned] = FALSE())
Downtime Incidents = COUNT(DowntimeAndSLA[downtime_id])
SLA Breaches = CALCULATE(COUNTROWS(DowntimeAndSLA), DowntimeAndSLA[downtime_duration_minutes] > 60)
```

#### Visualization Steps

1. Stacked column chart: `Planned Downtime` vs `Unplanned Downtime` by `server_id`  
2. Card: `Total Downtime Minutes`
3. Card: `Downtime Incidents`
4. Card: `SLA Breaches`
5. Line chart: Downtime trend over time

---

### 7. **Team Member Role Distribution & Coverage**

**Rename table to:** `TeamRoleDistribution`

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
    TeamRoleDistribution = Odbc.Query("dsn=PostgresTunnel", "
        SELECT tm.member_id, tm.team_id, tm.role, tmg.team_name
        FROM team_members tm
        LEFT JOIN team_management tmg ON tm.team_id = tmg.team_id
    ")
in
    TeamRoleDistribution
```

#### DAX

```dax
Total Team Members = COUNT(TeamRoleDistribution[member_id])
Unique Roles = DISTINCTCOUNT(TeamRoleDistribution[role])
Members Per Role = CALCULATE(COUNT(TeamRoleDistribution[member_id]), ALLEXCEPT(TeamRoleDistribution, TeamRoleDistribution[role]))
Small Teams =
CALCULATE(
    COUNTROWS(
        FILTER(
            SUMMARIZE(
                TeamRoleDistribution,
                TeamRoleDistribution[team_id],
                "MemberCount", COUNT(TeamRoleDistribution[member_id])
            ),
            [MemberCount] < 3
        )
    )
)
Members Multiple Roles =
CALCULATE(
    COUNTROWS(
        FILTER(
            SUMMARIZE(
                TeamRoleDistribution,
                TeamRoleDistribution[member_id],
                "RoleCount", DISTINCTCOUNT(TeamRoleDistribution[role])
            ),
            [RoleCount] > 1
        )
    )
)
```

#### Visualization Steps

1. Pie chart: `Members Per Role`
2. Bar chart: `Total Team Members` by `team_name`
3. Card: `Unique Roles`
4. Card: `Small Teams`
5. Card: `Members Multiple Roles`

---

### 8. **Geographical Distribution of Assets**

**Rename table to:** `GeoAssetDistribution`

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
    GeoAssetDistribution = Odbc.Query("dsn=PostgresTunnel", "
        SELECT l.location_id, l.location_name, l.country, l.region, sm.server_id, a.app_id, a.app_name, ir.incident_id
        FROM location l
        LEFT JOIN server_metrics sm ON l.location_id = sm.location_id
        LEFT JOIN applications a ON sm.server_id = a.app_id
        LEFT JOIN incident_response_logs ir ON sm.server_id = ir.server_id
    ")
in
    GeoAssetDistribution
```

#### DAX

```dax
Total Locations = COUNT(GeoAssetDistribution[location_id])
Servers Per Region = CALCULATE(COUNT(GeoAssetDistribution[server_id]), ALLEXCEPT(GeoAssetDistribution, GeoAssetDistribution[region]))
Applications Per Country = CALCULATE(COUNT(GeoAssetDistribution[app_id]), ALLEXCEPT(GeoAssetDistribution, GeoAssetDistribution[country]))
Incidents Per Location = CALCULATE(COUNT(GeoAssetDistribution[incident_id]), ALLEXCEPT(GeoAssetDistribution, GeoAssetDistribution[location_id]))
Locations Over 5 Incidents =
COUNTROWS(
    FILTER(
        SUMMARIZE(
            GeoAssetDistribution,
            GeoAssetDistribution[location_id],
            "IncidentCount", COUNT(GeoAssetDistribution[incident_id])
        ),
        [IncidentCount] > 5
    )
)
```

#### Visualization Steps

1. Map: `location_name` (location), `Total Locations` (size)
2. Bar chart: `Servers Per Region` by `region`
3. Bar chart: `Applications Per Country` by `country`
4. Table: `Incidents Per Location`
5. Card: `Locations Over 5 Incidents`

---

### 9. **Resource Allocation Efficiency**

**Rename table to:** `ResourceAllocationEfficiency`

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
    ResourceAllocationEfficiency = Odbc.Query("dsn=PostgresTunnel", "
        SELECT ra.server_id, ra.app_id, ra.allocated_memory, ra.allocated_cpu, ra.allocated_disk_space, ra.actual_memory_usage, ra.actual_cpu_usage, ra.actual_disk_usage, a.app_name
        FROM resource_allocation ra
        LEFT JOIN applications a ON ra.app_id = a.app_id
    ")
in
    ResourceAllocationEfficiency
```

#### DAX

```dax
Avg CPU Efficiency =
AVERAGEX(
    ResourceAllocationEfficiency,
    ResourceAllocationEfficiency[actual_cpu_usage] / ResourceAllocationEfficiency[allocated_cpu]
)
Avg Memory Efficiency =
AVERAGEX(
    ResourceAllocationEfficiency,
    ResourceAllocationEfficiency[actual_memory_usage] / ResourceAllocationEfficiency[allocated_memory]
)

Avg Disk Efficiency =
AVERAGEX(
    ResourceAllocationEfficiency,
    ResourceAllocationEfficiency[actual_disk_usage] / ResourceAllocationEfficiency[allocated_disk_space]
)
Apps Low CPU Efficiency = CALCULATE(DISTINCTCOUNT(ResourceAllocationEfficiency[app_id]), ResourceAllocationEfficiency[actual_cpu_usage] / ResourceAllocationEfficiency[allocated_cpu] < 0.5)
Servers Over Memory = CALCULATE(DISTINCTCOUNT(ResourceAllocationEfficiency[server_id]), ResourceAllocationEfficiency[actual_memory_usage] / ResourceAllocationEfficiency[allocated_memory] > 1)
```

#### Visualization Steps

1. Table: `cpu_efficiency`, `memory_efficiency`, `disk_efficiency` by `app_name`
2. Bar chart: `Avg CPU Efficiency`, `Avg Memory Efficiency`, `Avg Disk Efficiency`
3. Card: `Apps Low CPU Efficiency`
4. Card: `Servers Over Memory`

---

### 10. **User Access & Security Monitoring**

**Rename table to:** `UserAccessSecurity`

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
    UserAccessSecurity = Odbc.Query("dsn=PostgresTunnel", "
        SELECT ual.access_id, ual.user_id, ual.server_id, ual.access_type, ual.timestamp, u.username
        FROM user_access_logs ual
        LEFT JOIN users u ON ual.user_id = u.user_id
    ")
in
    UserAccessSecurity
```

#### DAX

```dax
Total Access Logs = COUNT(UserAccessSecurity[access_id])
Read Accesses = COUNTROWS(FILTER(UserAccessSecurity, UserAccessSecurity[access_type] = "READ"))
Write Accesses = COUNTROWS(FILTER(UserAccessSecurity, UserAccessSecurity[access_type] = "WRITE"))
Unique Users = DISTINCTCOUNT(UserAccessSecurity[user_id])
Active Users Last 7 Days = CALCULATE(DISTINCTCOUNT(UserAccessSecurity[user_id]), UserAccessSecurity[timestamp] >= TODAY()-7)
```

#### Visualization Steps

1. Table: `access_id`, `access_type`, `username`, `server_id`
2. Bar chart: `Read Accesses`, `Write Accesses` by `access_type`
3. Card: `Total Access Logs`
4. Card: `Unique Users`
5. Card: `Active Users Last 7 Days`

---
