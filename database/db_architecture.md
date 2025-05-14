# Database Architecture Summary (Current most up to date 09.05.2025 - DD.MM.YYYY)

This section provides an overview of the Cloud Infrastructure Monitoring Database (CIMD) schema, outlining the purpose of each table and its key columns.

* **server_metrics**: Stores real-time performance metrics for individual servers.
    * `server_id`: Identifier of the server.
    * `location_id`: Foreign key referencing the `location` table.
    * `timestamp`: Timestamp of the metric reading.
    * `cpu_usage`: Current CPU utilization percentage.
    * `memory_usage`: Current memory utilization percentage.
    * `disk_read_ops_per_sec`: Disk read operations per second.
    * `disk_write_ops_per_sec`: Disk write operations per second.
    * `network_in_bytes`: Number of bytes received on the network.
    * `network_out_bytes`: Number of bytes sent on the network.
    * `uptime_in_mins`: Uptime of the server in minutes.
    * `latency_in_ms`: Network latency in milliseconds.
    <!--* `db_queries_per_sec`: Database queries executed per second (if applicable).-->
    * `disk_usage_percent`: Current disk usage percentage.
    * `error_count`: Number of errors encountered since the last reading.
    * `disk_read_throughput`: Rate of data read from disk.
    * `disk_write_throughput`: Rate of data written to disk.


* **aggregated_metrics**: Stores hourly aggregated performance metrics for servers, providing a historical overview of resource utilization.
    * `server_id`: Identifier for the server.
    * `region`: Geographic region of the server.
    * `timestamp`: Timestamp of the aggregated metrics.
    * `hourly_avg_cpu_usage`: Hourly average CPU utilization.
    * `hourly_avg_memory_usage`: Hourly average memory utilization.
    * `peak_network_usage`: Peak network traffic during the hour.
    * `peak_disk_usage`: Peak disk I/O during the hour.
    * `uptime_percentage`: Percentage of uptime for the server during the hour.
    * `total_requests`: Total number of requests handled by the server during the hour.
    * `error_rate`: Rate of errors encountered by the server during the hour.
    * `average_response_time`: Average response time for requests during the hour.

* **alert_configuration**: Defines the rules and thresholds for generating alerts based on various metrics.
    * `alert_config_id`: Unique identifier for the alert configuration.
    * `server_id`: Identifier of the server this alert configuration applies to.
    * `metric_name`: Name of the metric to monitor (e.g., `cpu_usage`, `memory_usage`).
    * `threshold_value`: The value that triggers the alert.
    * `alert_frequency`: How often the alert should be triggered if the condition persists.
    * `contact_email`: Email address to send alert notifications to.
    * `alert_enabled`: Boolean indicating if the alert is currently active.
    * `alert_type`: Type of alert (e.g., `threshold`, `anomaly`).
    * `severity_level`: Severity of the alert (e.g., `critical`, `warning`, `info`).

* **alert_history**: Stores a record of all triggered alerts, including their status and resolution details.
    * `alert_id`: Unique identifier for the alert instance.
    * `server_id`: Identifier of the server that triggered the alert.
    * `alert_type`: Type of alert triggered.
    * `threshold_value`: The threshold that was breached (if applicable).
    * `alert_triggered_at`: Timestamp when the alert was triggered.
    * `resolved_at`: Timestamp when the alert was resolved (can be NULL).
    * `alert_status`: Current status of the alert (e.g., `open`, `resolved`, `acknowledged`).
    * `alert_severity`: Severity of the triggered alert.
    * `alert_description`: Detailed description of the alert.
    * `resolved_by`: User or system that resolved the alert (can be NULL).
    * `alert_source`: Component or system that generated the alert.
    * `impact`: Potential impact of the alert.

* **application_logs**: Stores detailed logs from various applications running on the monitored servers.
    * `log_id`: Unique identifier for the log entry.
    * `server_id`: Identifier of the server the log originated from.
    * `app_name`: Name of the application that generated the log.
    * `log_level`: Severity level of the log (e.g., `INFO`, `WARNING`, `ERROR`).
    * `error_code`: Specific error code associated with the log (if applicable).
    * `log_timestamp`: Timestamp of the log entry.
    * `trace_id`: Identifier for a specific request or transaction across multiple logs.
    * `span_id`: Identifier for a specific operation within a trace.
    * `source_ip`: IP address of the source of the log (if applicable).
    * `user_id`: Identifier of the user associated with the log (if applicable).
    * `log_source`: Specific source within the application that generated the log.
    * `app_id`: Identifier of the application.

* **applications**: A catalog of the applications being monitored.
    * `app_id`: Unique identifier for the application.
    * `app_name`: Name of the application.
    * `app_type`: Type of application (e.g., `web`, `database`, `middleware`).
    * `hosting_environment`: Environment where the application is hosted (e.g., `production`, `staging`, `development`).

* **cost_data**: Stores information about the cost of the cloud resources being monitored.
    * `server_id`: Identifier of the server the cost data is associated with.
    * `region`: Geographic region of the resource.
    * `timestamp`: Timestamp of the cost data.
    * `cost_per_hour`: Hourly cost of the resource.
    * `total_monthly_cost`: Calculated total monthly cost for the resource.
    * `team_allocation`: Team responsible for the cost.
    * `cost_per_day`: Calculated daily cost of the resource.
    * `cost_type`: Type of cost (e.g., `compute`, `storage`, `network`).
    * `cost_adjustment`: Any manual adjustments to the cost.
    * `cost_adjustment_reason`: Reason for the cost adjustment.
    * `cost_basis`: Basis for the cost calculation.

* **downtime_logs**: Records instances of server downtime.
    * `id`: Unique identifier for the downtime record.
    * `server_id`: Identifier of the affected server.
    * `start_time`: Timestamp when the downtime began.
    * `end_time`: Timestamp when the downtime ended (can be NULL if ongoing).
    * `downtime_duration_minutes`: Duration of the downtime in minutes.
    * `downtime_cause`: Reason for the downtime.
    * `sla_tracking`: Information related to Service Level Agreement (SLA) adherence.
    * `incident_id`: Identifier of the associated incident (if any).
    * `is_planned`: Boolean indicating if the downtime was planned.
    * `recovery_action`: Actions taken to recover from the downtime.
    * `downtime_id`: An alternative identifier for the downtime event.

* **error_logs**: Stores specific error events captured from the system or applications.
    * `error_id`: Unique identifier for the error log entry.
    * `server_id`: Identifier of the server where the error occurred.
    * `timestamp`: Timestamp of the error.
    * `error_severity`: Severity level of the error.
    * `error_message`: Detailed description of the error.
    * `resolved`: Boolean indicating if the error has been resolved.
    * `resolved_at`: Timestamp when the error was resolved (can be NULL).
    * `incident_id`: Identifier of the associated incident (if any).
    * `error_source`: Source of the error (e.g., application, system).
    * `error_code`: Specific error code.
    * `recovery_action`: Recommended or taken recovery actions.
    * `log_id`: Foreign key referencing the `application_logs` table (if applicable).

* **incident_response_logs**: Tracks the activities and details related to incident response.
    * `incident_id`: Unique identifier for the incident.
    * `server_id`: Identifier of the primary server affected by the incident.
    * `timestamp`: Timestamp of the log entry related to the incident response.
    * `response_team_id`: Identifier of the team responsible for responding to the incident.
    * `incident_summary`: Brief summary of the incident.
    * `access_id`: Identifier related to access during the incident response.
    * `resolution_time_minutes`: Time taken to resolve the incident in minutes.
    * `status`: Current status of the incident (e.g., `open`, `investigating`, `resolved`).
    * `priority_level`: Priority of the incident.
    * `incident_type`: Type of incident (e.g., `performance degradation`, `security breach`).
    * `root_cause`: Identified root cause of the incident.
    * `escalation_flag`: Boolean indicating if the incident was escalated.

* **location**: Stores geographical location information.
    * `location_id`: Unique identifier for the location.
    * `location_geom`: Geospatial data representing the exact coordinates of the location.
    * `country`: Country of the location.
    * `region`: Broader region of the location.
    * `location_name`: Name of the specific location.

* **members**: Contains information about team members who might be involved in managing the infrastructure.
    * `member_id`: Unique identifier for the team member.
    * `full_name`: Full name of the team member.
    * `email`: Email address of the team member.
    * `role`: Role of the team member (e.g., `engineer`, `manager`).
    * `department`: Department the team member belongs to.
    * `personal_email`: Personal email address of the team member.
    * `location_id`: Foreign key referencing the `location` table.

* **resource_allocation**: Details the allocation of resources (CPU, memory, disk) to servers and applications.
    * `server_id`: Identifier of the server.
    * `app_id`: Identifier of the application (can be NULL if allocated at the server level).
    * `workload_type`: Type of workload running on the allocated resources.
    * `allocated_memory`: Amount of memory allocated (e.g., in GB).
    * `allocated_cpu`: Number of CPU cores allocated.
    * `allocated_disk_space`: Amount of disk space allocated (e.g., in GB).
    * `resource_tag`: Optional tag for the resource allocation.
    * `timestamp`: Timestamp of the allocation record.
    * `utilization_percentage`: Current utilization percentage of the allocated resources.
    * `autoscaling_enabled`: Boolean indicating if autoscaling is enabled for these resources.
    * `max_allocated_memory`: Maximum allocated memory if autoscaling is enabled.
    * `max_allocated_cpu`: Maximum allocated CPU cores if autoscaling is enabled.
    * `max_allocated_disk_space`: Maximum allocated disk space if autoscaling is enabled.
    * `actual_memory_usage`: Current actual memory usage.
    * `actual_cpu_usage`: Current actual CPU usage.
    * `actual_disk_usage`: Current actual disk usage.
    * `cost_per_hour`: Hourly cost associated with the allocated resources.
    * `allocation_status`: Current status of the resource allocation.

* **spatial_ref_sys**: Standard table for storing spatial reference system definitions (often included by PostGIS extension).
    * `srid`: Spatial Reference System Identifier.
    * `auth_name`: Authority name for the SRS.
    * `auth_srid`: Authority-specific SRID.
    * `srtext`: Well-known text representation of the SRS.
    * `proj4text`: PROJ.4 representation of the SRS.

* **team_management**: Stores information about the teams responsible for managing the infrastructure.
    * `team_id`: Unique identifier for the team.
    * `team_name`: Name of the team.
    * `team_description`: Description of the team's responsibilities.
    * `team_lead_id`: Foreign key referencing the `members` table for the team lead.
    * `date_created`: Date when the team was created.
    * `status`: Current status of the team (e.g., `active`, `inactive`).
    * `location`: Primary location of the team.
    * `department`: Department the team belongs to.
    * `team_contact_email`: Email address for contacting the team.
    * `team_office_location_id`: Foreign key referencing the `location` table for the team's office.

* **team_members**: Links members to the teams they belong to.
    * `member_id`: Foreign key referencing the `members` table.
    * `team_id`: Foreign key referencing the `team_management` table.
    * `role`: Role of the member within the team.
    * `email`: Email address of the member within the team context.
    * `date_joined`: Date when the member joined the team.

* **team_server_assignment**: Links teams to the servers they are responsible for.
    * `team_id`: Foreign key referencing the `team_management` table.
    * `server_id`: Foreign key referencing the server (implicitly through other tables).

* **user_access_logs**: Records user access attempts to the monitored servers.
    * `access_id`: Unique identifier for the access log entry.
    * `user_id`: Identifier of the user attempting access (can be NULL for anonymous access).
    * `server_id`: Identifier of the server being accessed.
    * `access_type`: Type of access (e.g., `login`, `ssh`, `http`).
    * `timestamp`: Timestamp of the access attempt.
    * `access_ip`: IP address from which the access was attempted.
    * `user_agent`: User agent string of the client used for access.

* **users**: Contains information about users who might interact with the monitoring system or have access to the infrastructure.
    * `user_id`: Unique identifier for the user.
    * `username`: Username of the user.
    * `email`: Email address of the user.
    * `password_hash`: Hashed password of the user.
    * `full_name`: Full name of the user.
    * `date_joined`: Date when the user joined the system.
    * `last_login`: Timestamp of the user's last login.
    * `location_id`: Foreign key referencing the `location` table for the user's location.





