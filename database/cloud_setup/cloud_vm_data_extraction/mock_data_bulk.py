"""
Bulk insert script for 3 months of daily mock data.
Each day inserts the same number of rows as a single run in the original script.
Run this ONCE to populate your DB for Power BI testing.
bulk.py
"""

import random
import uuid
from datetime import datetime, timedelta, timezone
import psycopg2
from faker import Faker
import os
from uszipcode import SearchEngine

# --- CONFIGURABLE PARAMETERS ---
SERVER_IDS = [
    "550e8400-e29b-41d4-a716-446655440001",
    "b1e2d3c4-5f67-4a89-b012-3456789abcde",
    "c2f3e4d5-6a78-4b90-c123-456789abcdef",
    "d3a4b5c6-7b89-4c01-d234-56789abcdef0",
    "e4b5c6d7-8c90-4d12-e345-6789abcdef01",
    "f5c6d7e8-9d01-4e23-f456-789abcdef012",
    "a6d7e8f9-0e12-4f34-a567-89abcdef0123",
    "b7e8f9a0-1f23-4056-b678-9abcdef01234",
    "c8f9a0b1-2a34-4067-c789-abcdef012345",
    "d9a0b1c2-3b45-4078-d890-bcdef0123456"
]

SERVER_TO_LOCATION = {
    "550e8400-e29b-41d4-a716-446655440001": "11111111-1111-1111-1111-111111111111",
    "b1e2d3c4-5f67-4a89-b012-3456789abcde": "22222222-2222-2222-2222-222222222222",
    "c2f3e4d5-6a78-4b90-c123-456789abcdef": "33333333-3333-3333-3333-333333333333",
    "d3a4b5c6-7b89-4c01-d234-56789abcdef0": "44444444-4444-4444-4444-444444444444",
    "e4b5c6d7-8c90-4d12-e345-6789abcdef01": "55555555-5555-5555-5555-555555555555",
    "f5c6d7e8-9d01-4e23-f456-789abcdef012": "66666666-6666-6666-6666-666666666666",
    "a6d7e8f9-0e12-4f34-a567-89abcdef0123": "77777777-7777-7777-7777-777777777777",
    "b7e8f9a0-1f23-4056-b678-9abcdef01234": "88888888-8888-8888-8888-888888888888",
    "c8f9a0b1-2a34-4067-c789-abcdef012345": "99999999-9999-9999-9999-999999999999",
    "d9a0b1c2-3b45-4078-d890-bcdef0123456": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

LOG_LEVEL_ENUM = [
    "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"
]
LOG_SOURCE_ENUM = [
    "APP", "DATABASE", "SECURITY", "SYSTEM"
]

fake = Faker()
search = SearchEngine()
all_cities = search.by_population(lower=10000, returns=10000)

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def random_enum(enum_list):
    return random.choice(enum_list)

def random_uuid():
    return str(uuid.uuid4())

def random_ip():
    return fake.ipv4_public()

def random_bool():
    return random.choice([True, False])

def insert_server_metrics(cur, server_id, location_id, timestamp):
    cpu_usage = round(random.uniform(5, 80), 2)
    memory_usage = round(random.uniform(5, 80), 2)
    disk_read_ops_per_sec = random.randint(5, 200)
    disk_write_ops_per_sec = random.randint(5, 200)
    network_in_bytes = random.randint(100, 2000)
    network_out_bytes = random.randint(100, 2000)
    uptime_in_mins = random.randint(1000, 5000)
    latency_in_ms = round(random.uniform(0.5, 3), 3)
    disk_usage_percent = round(random.uniform(5, 80), 2)
    error_count = random.randint(2, 10)
    disk_read_throughput = random.randint(10000, 800000)
    disk_write_throughput = random.randint(10000, 800000)
    cur.execute("""
        INSERT INTO public.server_metrics (
            server_id, location_id, "timestamp", cpu_usage, memory_usage, disk_read_ops_per_sec,
            disk_write_ops_per_sec, network_in_bytes, network_out_bytes, uptime_in_mins, latency_in_ms,
            disk_usage_percent, error_count, disk_read_throughput, disk_write_throughput
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (server_id, location_id, timestamp, cpu_usage, memory_usage, disk_read_ops_per_sec,
          disk_write_ops_per_sec, network_in_bytes, network_out_bytes, uptime_in_mins, latency_in_ms,
          disk_usage_percent, error_count, disk_read_throughput, disk_write_throughput))

def insert_aggregated_metrics(cur, server_id, timestamp):
    region = fake.state_abbr()
    hourly_avg_cpu_usage = round(random.uniform(40, 80), 2)
    hourly_avg_memory_usage = round(random.uniform(40, 80), 2)
    peak_network_usage = random.randint(1600, 2000)
    peak_disk_usage = random.randint(65, 80)
    uptime_percentage = round(random.uniform(80, 100), 2)
    total_requests = random.randint(30000, 100000)
    error_rate = round(random.uniform(2, 8), 2)
    average_response_time = round(random.uniform(0.5, 100), 2)
    cur.execute("""
        INSERT INTO public.aggregated_metrics (
            server_id, region, "timestamp", hourly_avg_cpu_usage, hourly_avg_memory_usage,
            peak_network_usage, peak_disk_usage, uptime_percentage, total_requests, error_rate, average_response_time
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (server_id, region, timestamp, hourly_avg_cpu_usage, hourly_avg_memory_usage,
          peak_network_usage, peak_disk_usage, uptime_percentage, total_requests, error_rate, average_response_time))

def insert_alert_history(cur, server_id, timestamp):
    alert_id = random_uuid()
    alert_type = random_enum(['CPU', 'Memory', 'Disk', 'Network'])
    threshold_value = round(random.uniform(50, 100), 2)
    alert_triggered_at = timestamp
    resolved_at = alert_triggered_at + timedelta(minutes=random.randint(1, 60)) if random_bool() else None
    alert_status = random_enum(['OPEN', 'CLOSED'])
    alert_severity = random_enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
    alert_description = fake.sentence()
    resolved_by = fake.name() if resolved_at else None
    alert_source = random_enum(['SYSTEM', 'USER', 'MONITOR'])
    impact = random_enum(['Low', 'Medium', 'High', 'Critical'])
    cur.execute("""
        INSERT INTO public.alert_history (
            alert_id, server_id, alert_type, threshold_value, alert_triggered_at, resolved_at,
            alert_status, alert_severity, alert_description, resolved_by, alert_source, impact, "timestamp"
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (alert_id, server_id, alert_type, threshold_value, alert_triggered_at, resolved_at,
          alert_status, alert_severity, alert_description, resolved_by, alert_source, impact, timestamp))

def insert_application_logs(cur, server_id, app_id, user_id, timestamp):
    log_id = random_uuid()
    log_level = random_enum(LOG_LEVEL_ENUM)
    log_timestamp = timestamp
    trace_id = random_uuid()
    span_id = random_uuid()
    source_ip = random_ip()
    log_source = random_enum(LOG_SOURCE_ENUM)
    cur.execute("""
        INSERT INTO public.application_logs (
            log_id, server_id, log_level, log_timestamp, trace_id, span_id, source_ip, user_id, log_source, app_id, "timestamp"
        ) VALUES (%s, %s, %s::log_level_enum, %s, %s, %s, %s, %s, %s::log_source_enum, %s, %s)
    """, (log_id, server_id, log_level, log_timestamp, trace_id, span_id, source_ip, user_id, log_source, app_id, timestamp))
    return log_id

def insert_user_access_logs(cur, user_id, server_id, timestamp):
    access_id = random_uuid()
    access_type = random_enum(['READ', 'WRITE', 'DELETE', 'EXECUTE'])
    access_ip = random_ip()
    user_agent = fake.user_agent()
    cur.execute("""
        INSERT INTO public.user_access_logs (
            access_id, user_id, server_id, access_type, "timestamp", access_ip, user_agent
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (access_id, user_id, server_id, access_type, timestamp, access_ip, user_agent))

def insert_downtime_logs(cur, server_id, timestamp, incident_id=None):
    downtime_id = random_uuid()
    start_time = timestamp
    end_time = start_time + timedelta(minutes=random.randint(1, 120)) if random_bool() else None
    downtime_cause = fake.sentence()
    sla_tracking = random_bool()
    is_planned = random_bool()
    recovery_action = fake.sentence()
    cur.execute("""
        INSERT INTO public.downtime_logs (
            downtime_id, server_id, start_time, end_time, downtime_cause, sla_tracking, incident_id, is_planned, recovery_action, "timestamp"
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (downtime_id, server_id, start_time, end_time, downtime_cause, sla_tracking, incident_id, is_planned, recovery_action, timestamp))

def insert_error_logs(cur, server_id, timestamp, log_id, incident_id=None):
    error_id = random_uuid()
    error_severity = random_enum(['INFO', 'WARNING', 'CRITICAL'])
    error_message = fake.sentence()
    resolved = random_bool()
    resolved_at = timestamp + timedelta(minutes=random.randint(1, 60)) if resolved else None
    error_source = random_enum(['APP', 'SYSTEM', 'SECURITY', 'NETWORK'])
    error_code = str(random.randint(1000, 9999))
    recovery_action = fake.sentence()
    cur.execute("""
        INSERT INTO public.error_logs (
            error_id, server_id, "timestamp", error_severity, error_message, resolved, resolved_at,
            incident_id, error_source, error_code, recovery_action, log_id
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (error_id, server_id, timestamp, error_severity, error_message, resolved, resolved_at,
          incident_id, error_source, error_code, recovery_action, log_id))

def insert_incident_response_logs(cur, server_id, timestamp, team_id):
    incident_id = random_uuid()
    response_team_id = team_id
    incident_summary = fake.sentence()
    resolution_time_minutes = random.randint(1, 240)
    status = random_enum(['Open', 'In Progress', 'Resolved', 'Escalated'])
    priority_level = random_enum(['Low', 'Medium', 'High', 'Critical'])
    incident_type = random_enum(['hardware', 'software', 'network', 'security'])
    root_cause = fake.sentence()
    escalation_flag = random_bool()
    cur.execute("""
        INSERT INTO public.incident_response_logs (
            incident_id, server_id, "timestamp", response_team_id, incident_summary, resolution_time_minutes,
            status, priority_level, incident_type, root_cause, escalation_flag
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (incident_id, server_id, timestamp, response_team_id, incident_summary, resolution_time_minutes,
          status, priority_level, incident_type, root_cause, escalation_flag))
    return incident_id

def insert_team_server_assignment(cur, team_id, server_id, timestamp):
    cur.execute("""
        INSERT INTO public.team_server_assignment (team_id, server_id, "timestamp")
        VALUES (%s, %s, %s)
    """, (team_id, server_id, timestamp))

def get_random_member_id(cur):
    cur.execute("SELECT member_id FROM public.members ORDER BY random() LIMIT 1")
    result = cur.fetchone()
    return result[0] if result else None

def get_random_team_id(cur):
    cur.execute("SELECT team_id FROM public.team_management ORDER BY random() LIMIT 1")
    result = cur.fetchone()
    return result[0] if result else None

def get_random_app_id(cur):
    cur.execute("SELECT app_id FROM public.applications ORDER BY random() LIMIT 1")
    row = cur.fetchone()
    return row[0] if row else None

def main():
    GMT_PLUS_4 = timezone(timedelta(hours=4))
    DAYS = 90  # 3 months
    with get_conn() as conn, conn.cursor() as cur:
        print("DB connected", flush=True)
        for day in range(DAYS):
            timestamp = (datetime.now(GMT_PLUS_4) - timedelta(days=(DAYS - day - 1))).replace(hour=12, minute=0, second=0, microsecond=0)
            # Ensure locations exist
            cur.execute("SELECT user_id FROM public.users LIMIT 1")
            user_id = cur.fetchone()
            for i, server_id in enumerate(SERVER_IDS):
                location_id = SERVER_TO_LOCATION[server_id]
                app_id = get_random_app_id(cur)
                # Server Metrics
                insert_server_metrics(cur, server_id, location_id, timestamp)
                # Aggregated Metrics
                insert_aggregated_metrics(cur, server_id, timestamp)
                # Application Logs
                log_id = insert_application_logs(cur, server_id, app_id, user_id, timestamp)
                # User Access Logs
                insert_user_access_logs(cur, user_id, server_id, timestamp)
                # Error Logs
                cur.execute("SELECT incident_id FROM public.incident_response_logs ORDER BY random() LIMIT 1")
                incident_row = cur.fetchone()
                incident_id = incident_row[0] if incident_row else None
                insert_error_logs(cur, server_id, timestamp, log_id, incident_id)
            # Alert History
            cur.execute("SELECT server_id FROM public.server ORDER BY random() LIMIT 1")
            server_id = cur.fetchone()[0]
            team_id = get_random_team_id(cur)
            incident_id = insert_incident_response_logs(cur, server_id, timestamp, team_id)
            # Downtime Logs
            insert_downtime_logs(cur, server_id, timestamp, incident_id)
            print(f"Inserted rows for {timestamp.date()}", flush=True)
        conn.commit()
        print("Bulk insert complete!", flush=True)

if __name__ == "__main__":
    main()