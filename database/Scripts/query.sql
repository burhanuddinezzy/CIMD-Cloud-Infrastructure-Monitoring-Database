select * from public.server;
select * from server_metrics;
select*from team_management;
SELECT * FROM public.location; 
SELECT * FROM public.team_management;
SELECT * FROM public.team_members;
SELECT * FROM public.members;
SELECT * FROM public.users;
SELECT * FROM public.applications;
SELECT * FROM public.server_metrics;
SELECT * FROM public.aggregated_metrics;
SELECT * FROM public.alert_history;
SELECT * FROM public.application_logs;
SELECT * FROM public.resource_allocation;
SELECT * FROM public.user_access_logs;
SELECT * FROM public.alert_configuration;
SELECT * FROM public.cost_data;
SELECT * FROM public.downtime_logs;
SELECT * FROM public.error_logs;
SELECT * FROM public.incident_response_logs;
SELECT * FROM public.team_server_assignment;


SELECT team_id FROM public.team_management;
---
DELETE FROM public.server;
DELETE FROM server_metrics;

DELETE FROM team_management;

--DELETE FROM public.location;

DELETE FROM public.team_management;
DELETE FROM public.team_members;
DELETE FROM public.members;
DELETE FROM public.users;
--DELETE FROM public.applications;
DELETE FROM public.server_metrics;
DELETE FROM public.aggregated_metrics;
DELETE FROM public.alert_history;
DELETE FROM public.application_logs;
DELETE FROM public.resource_allocation;
DELETE FROM public.user_access_logs;
DELETE FROM public.alert_configuration;
DELETE FROM public.cost_data;
DELETE FROM public.downtime_logs;
DELETE FROM public.error_logs;
DELETE FROM public.incident_response_logs;
DELETE FROM public.team_server_assignment;

--To remove duplicate rows in public.location based on the location_geom column (keeping only one row per unique location_geom), you can use a query like this:
DELETE FROM public.location
WHERE ctid NOT IN (
SELECT min(ctid)
FROM public.location
GROUP BY location_geom
);



-- 1. Server Resource Utilization Over Time (for Grafana time series)
SELECT
    sm."timestamp",
    l.location_name,
    sm.server_id,
    sm.cpu_usage,
    sm.memory_usage,
    sm.disk_usage_percent,
    sm.network_in_bytes,
    sm.network_out_bytes
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
ORDER BY sm."timestamp" DESC;

-- 2. Average CPU and Memory Usage by Server (for Tableau bar chart) NOT WORKING
SELECT
    sm.server_id,
    l.location_name,
    ROUND(AVG(sm.cpu_usage), 2) AS avg_cpu,
    ROUND(AVG(sm.memory_usage), 2) AS avg_memory
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
GROUP BY sm.server_id, l.location_name
ORDER BY avg_cpu DESC;

-- 3. Application Resource Allocation and Utilization (for Tableau or Grafana)
SELECT
    a.app_name,
    ra.server_id,
    ra.allocated_cpu,
    ra.allocated_memory,
    ra.utilization_percentage,
    ra.autoscaling_enabled,
    ra.allocation_status
FROM public.resource_allocation ra
JOIN public.applications a ON ra.app_id = a.app_id;

-- 4. Team-wise Monthly Cost Summary (for Tableau)
SELECT
    tm.team_name,
    DATE_TRUNC('month', cd."timestamp") AS month,
    SUM(cd.total_monthly_cost) AS total_cost
FROM public.cost_data cd
JOIN public.team_management tm ON cd.team_allocation = tm.team_id
GROUP BY tm.team_name, month
ORDER BY month DESC, total_cost DESC;

-- 5. Top 10 Servers by Downtime (for Tableau or Grafana)
SELECT
    sm.server_id,
    l.location_name,
    COUNT(dl.downtime_id) AS downtime_events,
    SUM(dl.downtime_duration_minutes) AS total_downtime_minutes
FROM public.downtime_logs dl
JOIN public.server_metrics sm ON dl.server_id = sm.server_id AND dl."timestamp" = sm."timestamp"
JOIN public.location l ON sm.location_id = l.location_id
GROUP BY sm.server_id, l.location_name
ORDER BY total_downtime_minutes DESC
LIMIT 10;

-- 6. Incident Response Times by Team (for Tableau box plot or bar chart)
SELECT
    tm.team_name,
    irl.incident_id,
    irl.resolution_time_minutes,
    irl.status,
    irl.priority_level
FROM public.incident_response_logs irl
JOIN public.team_management tm ON irl.response_team_id = tm.team_id;

-- 7. Alert Volume and Severity Over Time (for Grafana time series)
SELECT
    DATE_TRUNC('day', ah."timestamp") AS day,
    ah.alert_severity,
    COUNT(*) AS alert_count
FROM public.alert_history ah
GROUP BY day, ah.alert_severity
ORDER BY day DESC, ah.alert_severity;

-- 8. Application Log Events by Level and Source (for Grafana pie/bar chart)
SELECT
    al.log_level,
    al.log_source,
    COUNT(*) AS log_count
FROM public.application_logs al
GROUP BY al.log_level, al.log_source
ORDER BY log_count DESC;

-- 9. User Access Patterns (for Tableau Sankey or bar chart)
SELECT
    u.username,
    l.location_name,
    ual.access_type,
    COUNT(*) AS access_count
FROM public.user_access_logs ual
JOIN public.users u ON ual.user_id = u.user_id
JOIN public.location l ON u.location_id = l.location_id
GROUP BY u.username, l.location_name, ual.access_type
ORDER BY access_count DESC;

-- 10. Error Events Linked to Applications (for troubleshooting dashboards)
SELECT
    a.app_name,
    el.error_severity,
    COUNT(*) AS error_count
FROM public.error_logs el
JOIN public.application_logs al ON el.log_id = al.log_id
JOIN public.applications a ON al.app_id = a.app_id
GROUP BY a.app_name, el.error_severity
ORDER BY error_count DESC;

-- 11. SLA Tracking: Planned vs Unplanned Downtime (for Tableau pie chart)
SELECT
    is_planned,
    COUNT(*) AS downtime_events,
    SUM(downtime_duration_minutes) AS total_minutes
FROM public.downtime_logs
GROUP BY is_planned;

-- 12. Team Members by Role (for org charts or bar charts)
SELECT
    tm.team_name,
    tmem.role,
    COUNT(*) AS member_count
FROM public.team_members tmem
JOIN public.team_management tm ON tmem.team_id = tm.team_id
GROUP BY tm.team_name, tmem.role
ORDER BY tm.team_name, member_count DESC;


-- 1. Server Health Dashboard: Identify servers with consistently high CPU or memory usage over the past week
-- Useful for proactive infrastructure scaling and identifying bottlenecks
SELECT
    sm.server_id,
    l.location_name,
    ROUND(AVG(sm.cpu_usage), 2) AS avg_cpu_usage,
    ROUND(AVG(sm.memory_usage), 2) AS avg_memory_usage,
    COUNT(*) FILTER (WHERE sm.cpu_usage > 85) AS high_cpu_events,
    COUNT(*) FILTER (WHERE sm.memory_usage > 85) AS high_memory_events
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
WHERE sm."timestamp" >= NOW() - INTERVAL '7 days'
GROUP BY sm.server_id, l.location_name
HAVING COUNT(*) FILTER (WHERE sm.cpu_usage > 85) > 5 OR COUNT(*) FILTER (WHERE sm.memory_usage > 85) > 5
ORDER BY avg_cpu_usage DESC, avg_memory_usage DESC;

-- 2. Cost Efficiency: Monthly cost per team vs. average server utilization
-- Helps finance and engineering teams optimize resource allocation and reduce waste
SELECT
    tm.team_name,
    DATE_TRUNC('month', cd."timestamp") AS month,
    SUM(cd.total_monthly_cost) AS total_cost,
    ROUND(AVG(sm.cpu_usage), 2) AS avg_cpu_usage,
    ROUND(AVG(sm.memory_usage), 2) AS avg_memory_usage
FROM public.cost_data cd
JOIN public.team_management tm ON cd.team_allocation = tm.team_id
JOIN public.server_metrics sm ON cd.server_id = sm.server_id AND cd."timestamp" = sm."timestamp"
GROUP BY tm.team_name, month
ORDER BY total_cost DESC;

-- 3. Incident Root Cause Analysis: Top root causes and their impact by team and incident type
-- Enables targeted improvements in reliability and incident response
SELECT
    tm.team_name,
    irl.incident_type,
    irl.root_cause,
    COUNT(*) AS incident_count,
    ROUND(AVG(irl.resolution_time_minutes), 1) AS avg_resolution_time,
    SUM(dl.downtime_duration_minutes) AS total_downtime_minutes
FROM public.incident_response_logs irl
JOIN public.team_management tm ON irl.response_team_id = tm.team_id
LEFT JOIN public.downtime_logs dl ON irl.incident_id = dl.incident_id
GROUP BY tm.team_name, irl.incident_type, irl.root_cause
ORDER BY incident_count DESC, total_downtime_minutes DESC;

-- 4. Security & Compliance: Unusual access patterns (users accessing servers outside their location)
-- Useful for detecting potential security breaches or policy violations
SELECT
    u.username,
    l_user.location_name AS user_location,
    l_server.location_name AS server_location,
    COUNT(*) AS access_count
FROM public.user_access_logs ual
JOIN public.users u ON ual.user_id = u.user_id
JOIN public.server_metrics sm ON ual.server_id = sm.server_id AND ual."timestamp" = sm."timestamp"
JOIN public.location l_user ON u.location_id = l_user.location_id
JOIN public.location l_server ON sm.location_id = l_server.location_id
WHERE l_user.location_name <> l_server.location_name
GROUP BY u.username, user_location, server_location
ORDER BY access_count DESC;

-- 5. Alert Effectiveness: Mean time to resolution (MTTR) for critical alerts by team and month
-- Key SRE/DevOps metric for measuring operational excellence
SELECT
    tm.team_name,
    DATE_TRUNC('month', ah."timestamp") AS month,
    COUNT(*) AS critical_alerts,
    ROUND(AVG(EXTRACT(EPOCH FROM (ah.resolved_at - ah.alert_triggered_at))/60), 2) AS avg_minutes_to_resolve
FROM public.alert_history ah
JOIN public.server_metrics sm ON ah.server_id = sm.server_id AND ah."timestamp" = sm."timestamp"
JOIN public.team_server_assignment tsa ON sm.server_id = tsa.server_id
JOIN public.team_management tm ON tsa.team_id = tm.team_id
WHERE ah.alert_severity = 'CRITICAL' AND ah.resolved_at IS NOT NULL
GROUP BY tm.team_name, month
ORDER BY month DESC, critical_alerts DESC;

-- 6. Application Performance: Top 5 applications with the highest average response time in the last month
-- Helps identify apps that may need optimization or scaling
SELECT
    a.app_name,
    ROUND(AVG(am.average_response_time), 2) AS avg_response_time_ms
FROM public.aggregated_metrics am
JOIN public.resource_allocation ra ON am.server_id = ra.server_id
JOIN public.applications a ON ra.app_id = a.app_id
WHERE am."timestamp" >= NOW() - INTERVAL '1 month'
GROUP BY a.app_name
ORDER BY avg_response_time_ms DESC
LIMIT 5;

-- 7. Error Hotspots: Servers with the most critical errors in the past 30 days
-- Useful for reliability engineering and root cause analysis
SELECT
    sm.server_id,
    l.location_name,
    COUNT(*) AS critical_error_count
FROM public.error_logs el
JOIN public.server_metrics sm ON el.server_id = sm.server_id AND el."timestamp" = sm."timestamp"
JOIN public.location l ON sm.location_id = l.location_id
WHERE el.error_severity = 'CRITICAL' AND el."timestamp" >= NOW() - INTERVAL '30 days'
GROUP BY sm.server_id, l.location_name
ORDER BY critical_error_count DESC
LIMIT 10;

-- 8. User Engagement: Most active users by access type and application
-- Great for understanding usage patterns and potential power users
SELECT
    u.username,
    a.app_name,
    ual.access_type,
    COUNT(*) AS access_count
FROM public.user_access_logs ual
JOIN public.users u ON ual.user_id = u.user_id
JOIN public.resource_allocation ra ON ual.server_id = ra.server_id
JOIN public.applications a ON ra.app_id = a.app_id
GROUP BY u.username, a.app_name, ual.access_type
ORDER BY access_count DESC
LIMIT 20;

-- 9. Alert Fatigue: Teams with the highest number of alerts per server
-- Useful for SRE/DevOps to identify teams that may be overwhelmed by noise
SELECT
    tm.team_name,
    COUNT(ah.alert_id) AS alert_count,
    COUNT(DISTINCT tsa.server_id) AS server_count,
    ROUND(COUNT(ah.alert_id)::numeric / GREATEST(COUNT(DISTINCT tsa.server_id),1), 2) AS alerts_per_server
FROM public.alert_history ah
JOIN public.team_server_assignment tsa ON ah.server_id = tsa.server_id
JOIN public.team_management tm ON tsa.team_id = tm.team_id
GROUP BY tm.team_name
ORDER BY alerts_per_server DESC;

-- 10. SLA Compliance: Percentage of downtime events tracked for SLA by team and month
-- Key for customer success and compliance reporting
SELECT
    tm.team_name,
    DATE_TRUNC('month', dl."timestamp") AS month,
    COUNT(*) AS total_downtime_events,
    COUNT(*) FILTER (WHERE dl.sla_tracking) AS sla_tracked_events,
    ROUND(100.0 * COUNT(*) FILTER (WHERE dl.sla_tracking) / NULLIF(COUNT(*),0), 2) AS sla_tracking_pct
FROM public.downtime_logs dl
JOIN public.server_metrics sm ON dl.server_id = sm.server_id AND dl."timestamp" = sm."timestamp"
JOIN public.team_server_assignment tsa ON sm.server_id = tsa.server_id
JOIN public.team_management tm ON tsa.team_id = tm.team_id
GROUP BY tm.team_name, month
ORDER BY month DESC, sla_tracking_pct DESC;


-- 1. Find all servers within 50km of a given city (e.g., "San Francisco")
-- Useful for regional monitoring, compliance, or disaster recovery planning
SELECT
    l.location_name,
    sm.server_id,
    sm."timestamp",
    sm.cpu_usage,
    sm.memory_usage
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
WHERE ST_DWithin(
    l.location_geom::geography,
    (SELECT location_geom FROM public.location WHERE location_name = 'Miami' LIMIT 1)::geography,
    50000 -- meters (50km)
);

-- 2. Aggregate average CPU usage by region (spatial grouping) NOT WORKING
-- Great for heatmaps or regional performance dashboards
SELECT
    l.region,
    ROUND(AVG(sm.cpu_usage), 2) AS avg_cpu_usage,
    ROUND(AVG(sm.memory_usage), 2) AS avg_memory_usage
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
GROUP BY l.region
ORDER BY avg_cpu_usage DESC;

-- 3. Identify the nearest server to each team office (proximity analysis)
-- Useful for optimizing latency or assigning support responsibilities
SELECT
    tm.team_name,
    l_office.location_name AS office_location,
    l_server.location_name AS nearest_server_location,
    sm.server_id,
    ST_Distance(l_office.location_geom::geography, l_server.location_geom::geography) AS distance_meters
FROM public.team_management tm
JOIN public.location l_office ON tm.team_office_location_id = l_office.location_id
JOIN LATERAL (
    SELECT sm.server_id, l2.location_name, l2.location_geom
    FROM public.server_metrics sm
    JOIN public.location l2 ON sm.location_id = l2.location_id
    ORDER BY l_office.location_geom <-> l2.location_geom
    LIMIT 1
) AS nearest ON TRUE
JOIN public.location l_server ON nearest.location_name = l_server.location_name;

-- 4. Count of incidents by proximity to a specific location (e.g., within 100km of "New York")
-- Useful for risk assessment and regional incident management
SELECT
    COUNT(*) AS incident_count,
    l.location_name AS nearby_city
FROM public.incident_response_logs irl
JOIN public.server_metrics sm ON irl.server_id = sm.server_id AND irl."timestamp" = sm."timestamp"
JOIN public.location l ON sm.location_id = l.location_id
WHERE ST_DWithin(
    l.location_geom::geography,
    (SELECT location_geom FROM public.location WHERE location_name = 'Miami' LIMIT 1)::geography,
    100000 -- meters (100km)
)
GROUP BY l.location_name
ORDER BY incident_count DESC;

-- 5. Visualize server density by region using centroid clustering (for mapping dashboards) NOT WORKING
-- Useful for infrastructure planning and identifying over/under-served regions
SELECT
    l.region,
    COUNT(DISTINCT sm.server_id) AS server_count,
    ST_Centroid(ST_Collect(l.location_geom)) AS region_centroid
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
GROUP BY l.region;

-- 1. Regional Outage Impact: Find all teams whose office is within 100km of a server that experienced critical downtime in the last 24 hours
SELECT
    tm.team_name,
    l_office.location_name AS team_office,
    l_server.location_name AS affected_server_location,
    dl.downtime_id,
    dl.start_time,
    dl.end_time,
    dl.downtime_duration_minutes
FROM public.downtime_logs dl
JOIN public.server_metrics sm ON dl.server_id = sm.server_id AND dl."timestamp" = sm."timestamp"
JOIN public.location l_server ON sm.location_id = l_server.location_id
JOIN public.team_management tm ON TRUE
JOIN public.location l_office ON tm.team_office_location_id = l_office.location_id
WHERE dl.downtime_duration_minutes > 30
  AND dl.start_time >= NOW() - INTERVAL '24 hours'
  AND ST_DWithin(
        l_office.location_geom::geography,
        l_server.location_geom::geography,
        100000 -- 100km
  );

-- 2. Server Load Balancing: For each region, find the server farthest from the region centroid and its average CPU usage
SELECT
    l.region,
    sm.server_id,
    l.location_name,
    ROUND(AVG(sm.cpu_usage), 2) AS avg_cpu_usage,
    ST_Distance(
        l.location_geom::geography,
        ST_Centroid(ST_Collect(l2.location_geom))::geography
    ) AS distance_from_centroid_m
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
JOIN public.location l2 ON l2.region = l.region
GROUP BY l.region, sm.server_id, l.location_name, l.location_geom
ORDER BY l.region, distance_from_centroid_m DESC;

-- 3. Incident Clustering: Identify "hotspots" (cities with the most incidents within 50km radius)
SELECT
    l.location_name AS hotspot_city,
    COUNT(irl.incident_id) AS incident_count
FROM public.incident_response_logs irl
JOIN public.server_metrics sm ON irl.server_id = sm.server_id AND irl."timestamp" = sm."timestamp"
JOIN public.location l ON sm.location_id = l.location_id
WHERE EXISTS (
    SELECT 1 FROM public.location l2
    WHERE ST_DWithin(l.location_geom::geography, l2.location_geom::geography, 50000)
)
GROUP BY l.location_name
ORDER BY incident_count DESC
LIMIT 10;

SELECT *
FROM server_metrics
WHERE timestamp >= (SELECT MAX(timestamp)::date FROM server_metrics);


-- 4. Compliance: List all servers outside the United States (by country field) and their recent error counts
SELECT
    sm.server_id,
    l.location_name,
    l.country,
    COUNT(el.error_id) AS error_count_last_7d
FROM public.server_metrics sm
JOIN public.location l ON sm.location_id = l.location_id
LEFT JOIN public.error_logs el ON sm.server_id = el.server_id AND el."timestamp" >= NOW() - INTERVAL '7 days'
WHERE l.country <> 'United States'
GROUP BY sm.server_id, l.location_name, l.country
ORDER BY error_count_last_7d DESC;

-- 5. Proximity Alert: For each team, find the nearest server with a critical alert in the last week and the distance to it
SELECT
    tm.team_name,
    l_office.location_name AS team_office,
    l_server.location_name AS server_location,
    ah.alert_id,
    ah.alert_severity,
    ah.alert_triggered_at,
    ST_Distance(
        l_office.location_geom::geography,
        l_server.location_geom::geography
    ) AS distance_meters
FROM public.alert_history ah
JOIN public.server_metrics sm ON ah.server_id = sm.server_id AND ah."timestamp" = sm."timestamp"
JOIN public.location l_server ON sm.location_id = l_server.location_id
JOIN public.team_management tm ON TRUE
JOIN public.location l_office ON tm.team_office_location_id = l_office.location_id
WHERE ah.alert_severity = 'CRITICAL'
  AND ah.alert_triggered_at >= NOW() - INTERVAL '7 days'
ORDER BY tm.team_name, distance_meters ASC;

---
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_level_enum') THEN
        CREATE TYPE log_level_enum AS ENUM (
            'DEBUG', 'INFO', 'NOTICE', 'WARNING', 'ERROR', 'CRITICAL', 'ALERT', 'EMERGENCY'
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_source_enum') THEN
        CREATE TYPE log_source_enum AS ENUM (
            'APP', 'SYSTEM', 'SECURITY', 'NETWORK', 'DATABASE', 'API', 'USER', 'SCHEDULER', 'MONITOR'
        );
    END IF;
END$$;

INSERT INTO public.server (server_id, location_id)
VALUES ('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001');