# Project: End-to-End Observability & Business Intelligence Platform

**Objective:**  
To design and implement a robust data pipeline capable of ingesting diverse telemetry data (server metrics, application logs), storing it in purpose-built databases, and visualizing it through both operational and business intelligence dashboards. This project demonstrates proficiency in modern data stacks, data transformation, and multi-source data integration.

---

## Key Technologies

- **Data Collection:** Telegraf  
- **Relational Database:** PostgreSQL  
- **Specialized Log Store:** Elasticsearch  
- **Operational Dashboards:** Grafana  
- **Business Intelligence Dashboards:** Tableau / Power BI  
- **Orchestration/Processing:** Custom Python Scripts (or similar logic)  

---

## Architectural Components & Data Flow

This project employs a hybrid data storage strategy, leveraging the strengths of both relational and NoSQL databases to handle different data types effectively.

### 1. Data Ingestion & Storage

**Telegraf (Data Collector):**  
Deployed on the monitored server, Telegraf acts as the primary data collection agent.

#### System Metrics Flow (Live Ingestion):

- Telegraf collects real-time server performance metrics (CPU, Memory, Disk I/O, network I/O, uptime, latency) from the operating system.
- **Destination:** Directly ingested into the PostgreSQL `server_metrics` table.

#### Web Server Application Logs Flow (Live Ingestion):

- Telegraf collects raw Nginx access and error logs from the web server.
- **Destination:** Ingested into Elasticsearch, which is optimized for high-volume, semi-structured log data with powerful search capabilities.

---

### PostgreSQL Database (Structured Data Hub)

Serves as the central relational database for highly structured data, metrics, and derived operational insights.

#### Tables with Live Data Ingestion (via Telegraf or Custom Scripts):

- `server_metrics`: Stores real-time performance metrics for individual servers (e.g., cpu_usage, memory_usage, network_in_bytes).
- `error_logs`: Stores classified and actionable error events. This table is populated by Custom Python Scripts that process and categorize raw Nginx error logs originating from Elasticsearch.

#### Tables Populated with Mock Data (for Project Scope Demonstration):

- `application_logs`: Stores detailed, structured logs from various applications. While designed for potential ingestion from a custom application (which I'm not going to build as it will increase SOW a good bit; And the SOW has already increase quite a bit. This project needs to come to an end at some point.), for this project, these logs mock log data.
- `alert_configuration`: Defines rules and thresholds for generating alerts.
- `applications`: A catalog of monitored applications.
- `cost_data`: Tracks cloud resource costs.
- `location`: Stores geographical location information.
- `members`: Contains team member details.
- `team_management`: Stores team information.
- `team_members`: Links members to teams.
- `team_server_assignment`: Links teams to servers.
- `user_access_logs`: Records user access attempts.
- `users`: Contains user information.
- `incident_response_logs`: Tracks incident response activities.
- `resource_allocation`: Details resource allocation to servers/applications.

#### Tables Populated from Other Tables (Derived/Aggregated Data):

- `aggregated_metrics`: Stores hourly aggregated performance metrics, derived from `server_metrics`.
- `alert_history`: Stores a record of all triggered alerts, derived from `alert_configuration` and real-time metric/log analysis. (This may be pushed to mock data side if it doesnt receive enough data. alert_configuration will be set such alerts are triggered at normal usage from server_metrics since I don't expect any real alert level usage from server_metrics since there isn't much that will happen to cause that)
- `downtime_logs`: Records instances of server downtime, populated by Custom Python Scripts analyzing metrics from `server_metrics` and relevant application status from logs (from Elasticsearch).

---

### Elasticsearch (Raw Log Store)

- Serves as a specialized NoSQL database for ingesting and indexing high volumes of raw, semi-structured Nginx web server access and error logs.
- Optimized for fast, full-text search, filtering, and real-time analytical queries on raw log data streams.

---

### Custom Python Scripts (Data Transformation & Alerting Logic)

- These scripts act as middleware, performing crucial data processing and business logic.
- They read raw logs from Elasticsearch (for Nginx errors and access logs) and metrics from PostgreSQL (`server_metrics`).
- They then process, classify, and aggregate this data, subsequently populating the structured `error_logs`, `application_logs` (from Nginx access logs), and `downtime_logs` tables within PostgreSQL based on predefined rules. This logic also incorporates the `alert_configuration` table.

---

## 2. Data Visualization & Analysis

### Grafana (Operational & DevOps Dashboards)

- **Purpose:** Provides real-time operational monitoring, troubleshooting dashboards for DevOps/SRE teams.
- **Data Sources:** Directly connects to Elasticsearch for live Nginx log analytics and troubleshooting (e.g., HTTP status codes, request rates, error message trends). It also connects to PostgreSQL to visualize server performance metrics (`server_metrics`) and derived operational events (`error_logs`, `downtime_logs`).
- **Use Cases:** Server health monitoring, Nginx traffic analysis, error log investigation, and incident tracking.

### Tableau / Power BI (Business Intelligence Dashboards)

- **Purpose:** Used for higher-level business intelligence, strategic analysis, and historical reporting.
- **Data Source:** Connects primarily to the PostgreSQL database, leveraging its structured nature.
- **Use Cases:** Analyzing historical trends in server performance, incident frequencies, error rates, application usage patterns (from mock data in `application_logs` and other business tables), and overall system uptime for SLA reporting.

---

## Skills Demonstrated

- **End-to-End Data Pipeline Design & Implementation**
- **Data Ingestion & Collection:** Telegraf (system metrics, web server logs)
- **Database Management:** PostgreSQL (design, administration, diverse table types)
- **Specialized Data Stores:** Elasticsearch (log management, full-text search)
- **Data Transformation & Processing:** Custom Python Scripting (ETL, data enrichment, classification, rule-based processing)
- **Monitoring & Observability:** Grafana (dashboarding, multi-source integration for operational insights)
- **Business Intelligence:** Tableau / Power BI (connecting to relational data for strategic reporting)
- **Architectural Design:** Choosing the right tool for the right data type, integrating disparate systems for a holistic view.
- **Incident Management Concepts:** Implementing tables for alerts, incidents, and downtime.
- **Pragmatic Development:** Adapting project scope (e.g., using mock data) to achieve learning goals efficiently.

---

## Diagram: Data Flow Overview

```mermaid
graph TD
    subgraph Server [Monitored Server (VM)]
        Nginx --- Telegraf
        OS_Metrics[OS Metrics] --- Telegraf
    end

    subgraph Data Ingestion & Storage
        Telegraf -->|System Metrics| PostgreSQL[PostgreSQL DB]
        Telegraf -->|Raw Nginx Logs| Elasticsearch[Elasticsearch]
        
        Elasticsearch -->|Nginx Error Logs| CustomScript[Custom Python Script]
        Application logs are collected by Elasticsearch and used directly in Grafana, no custom script

        CustomScript -->|Processed Errors| PostgreSQL

        PostgreSQL -->|vmserver_metrics| Dashboard_Grafana[Grafana]
        PostgreSQL -->|error_logs| Dashboard_Grafana
        PostgreSQL -->|downtime_logs| Dashboard_Grafana
        PostgreSQL -->|All Structured Data| Dashboard_BI[Tableau / Power BI]
        Elasticsearch -->|Nginx Access Logs| Dashboard_Grafana
    end

    subgraph Dashboards
        Dashboard_Grafana
        Dashboard_BI
    end

    subgraph PostgreSQL Tables
        T1(vmserver_metrics)
        T2(alert_configuration - Mock)
        T3(applications - Mock)
        T4(cost_data - Mock)
        T5(location - Mock)
        T6(members - Mock)
        T7(team_management - Mock)
        T8(team_members - Mock)
        T9(team_server_assignment - Mock)
        T10(user_access_logs - Mock)
        T11(users - Mock)
        T12(incident_response_logs - Mock)
        T13(resource_allocation - Mock)
        T14(application_logs - Live Processed)
        T15(error_logs - Live Processed)
        T16(downtime_logs - Live Processed)
        T17(aggregated_metrics - Derived)
        T18(alert_history - Derived)
        PostgreSQL --- T1 & T2 & T3 & T4 & T5 & T6 & T7 & T8 & T9 & T10 & T11 & T12 & T13 & T14 & T15 & T16 & T17 & T18
    end

    subgraph Elasticsearch Indices
        E1(nginx-logs-daily-index)
        Elasticsearch --- E1
    end

    Nginx -.->|Generate| E1
    OS_Metrics -.->|Generate| T1

    CustomScript -->|Populates| T14
    CustomScript -->|Populates| T15
    CustomScript -->|Populates| T16

    T1 -->|Derives| T17
    T2 --.->|Rules For| CustomScript
    T1 --.->|Triggers| CustomScript
    E1 --.->|Triggers| CustomScript

    T16 --.->|Feeds| T18
    T15 --.->|Feeds| T18
    T1 --.->|Feeds| T17
    T1 --.->|Feeds| T16

    Dashboard_Grafana -->|Queries| E1
    Dashboard_Grafana -->|Queries| T1 & T14 & T15 & T16 & T17 & T18

    Dashboard_BI -->|Queries| T1 & T2 & T3 & T4 & T5 & T6 & T7 & T8 & T9 & T10 & T11 & T12 & T13 & T14 & T15 & T16 & T17 & T18
```