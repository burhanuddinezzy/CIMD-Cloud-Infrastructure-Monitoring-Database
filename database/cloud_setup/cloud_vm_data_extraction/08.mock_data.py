"""
This script will be placed on the cloud VM and run nonstop, generating mock data for all tables in the database.
It maintains referential integrity, uses real locations, and generates realistic, rich data using Faker.
Note. Run this on the VM! Not local!

File name on VM is mock.py"""

import time
import random
import uuid
from datetime import datetime, timedelta
import psycopg2
from faker import Faker
import os
from uszipcode import SearchEngine
import requests

# --- CONFIGURABLE PARAMETERS ---
ROWS_PER_RUN = 10
SLEEP_SECONDS = 10  # Interval between data generation cycles

# --- DB CONNECTION ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),  # No ${}
}

# --- ENUMS (for creation if not exists) ---
LOG_LEVEL_ENUM = [
    "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"
]
LOG_SOURCE_ENUM = [
    "APP", "DATABASE", "SECURITY", "SYSTEM"
]

# --- SETUP ---
fake = Faker()
Faker.seed(42)
random.seed(42)

search = SearchEngine()  # Remove simple_zipcode=True
all_cities = search.by_population(lower=10000, returns=10000)

# --- UTILITY FUNCTIONS ---

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

# Only needed to run once, and it has been run, keeping it here for referencing enums
'''def create_enums(): 
    with get_conn() as conn, conn.cursor() as cur:
        # log_level_enum
        cur.execute("""
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_level_enum') THEN
                    CREATE TYPE log_level_enum AS ENUM ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL');
                END IF;
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'log_source_enum') THEN
                    CREATE TYPE log_source_enum AS ENUM ('APP', 'SYSTEM', 'SECURITY', 'NETWORK');
                END IF;
            END$$;
        """)
        conn.commit()'''

def random_geography_point(lat, lng):
    return f"SRID=4326;POINT({lng} {lat})"

def random_password_hash():
    return fake.sha256()

def random_ip():
    return fake.ipv4_public()

def random_interval():
    return f"{random.randint(1, 24)} hours"

def random_bool():
    return random.choice([True, False])

def random_enum(enum_list):
    return random.choice(enum_list)

def random_timestamp(start=None, end=None):
    if not start:
        start = datetime.now() - timedelta(days=30)
    if not end:
        end = datetime.now()
    return fake.date_time_between(start_date=start, end_date=end)

def random_uuid():
    return str(uuid.uuid4())

def random_us_location():
    city_obj = random.choice(all_cities)
    city = city_obj.major_city
    state = city_obj.state
    country = "United States"
    lat = city_obj.lat
    lng = city_obj.lng
    return city, country, state, lat, lng

def generate_team_name_and_department():
    # Use Faker to generate a department and a team name based on it
    department = fake.job() + " Department"
    # Make the team name more realistic (e.g., "Marketing Team", "Engineering Team")
    team_core = fake.bs().split()[0].capitalize()  # e.g., "Marketing", "Operations"
    team_name = f"{team_core} Team"
    return team_name, department

def generate_team_description(team_name):
    """
    Use a free AI model API (HuggingFace Inference API) to generate a team description.
    If the API fails, fallback to a simple fake sentence.
    """
    try:
        # HuggingFace Inference API for text generation (no API key needed for small requests)
        api_url = "https://api-inference.huggingface.co/models/gpt2"
        prompt = f"Describe the purpose and responsibilities of the {team_name} in a company."
        response = requests.post(
            api_url,
            headers={"Accept": "application/json"},
            json={"inputs": prompt, "parameters": {"max_new_tokens": 40}}
        )
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and len(data) > 0 and "generated_text" in data[0]:
                return data[0]["generated_text"].strip()
            elif isinstance(data, dict) and "generated_text" in data:
                return data["generated_text"].strip()
        # fallback if API fails or returns unexpected format
    except Exception:
        pass
    return fake.sentence(nb_words=12)

# --- DATA GENERATION FUNCTIONS ---

def insert_location(cur):
    city, country, region, lat, lng = random_us_location()
    location_id = random_uuid()
    location_geom = random_geography_point(lat, lng)
    location_name = city
    cur.execute("""
        INSERT INTO public.location (location_id, location_geom, country, region, location_name)
        VALUES (%s, ST_GeogFromText(%s), %s, %s, %s)
        RETURNING location_id
    """, (location_id, location_geom, country, region, location_name))
    return location_id

def insert_team_management(cur, location_id, team_lead_id=None, team_id=None):
    # Ensure unique team_name
    while True:
        team_name, department = generate_team_name_and_department()
        cur.execute("SELECT 1 FROM public.team_management WHERE team_name = %s", (team_name,))
        if not cur.fetchone():
            break
    if not team_id:
        team_id = random_uuid()
    team_description = generate_team_description(team_name)
    # Ensure unique team_contact_email
    while True:
        team_contact_email = fake.company_email()
        cur.execute("SELECT 1 FROM public.team_management WHERE team_contact_email = %s", (team_contact_email,))
        if not cur.fetchone():
            break
    cur.execute("""
        INSERT INTO public.team_management (team_id, team_name, team_description, team_lead_id, department, team_contact_email, team_office_location_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING team_id
    """, (team_id, team_name, team_description, team_lead_id, department, team_contact_email, location_id))
    return team_id, team_contact_email

def insert_team_members(cur, team_id, member_id=None):
    if not member_id:
        member_id = random_uuid()
    roles = [
        'Cloud Engineer', 'DevOps', 'Security', 'DBA', 'Network Engineer', 'Support'
    ]
    role = random_enum(roles)
    # Ensure unique email
    while True:
        email = fake.email()
        cur.execute("SELECT 1 FROM public.team_members WHERE email = %s", (email,))
        if not cur.fetchone():
            break
    date_joined = random_timestamp()
    cur.execute("""
        INSERT INTO public.team_members (member_id, team_id, role, email, date_joined)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING member_id
    """, (member_id, team_id, role, email, date_joined))
    return member_id

def insert_members(cur, location_id):
    member_id = random_uuid()
    full_name = fake.name()
    personal_email = fake.email()
    cur.execute("""
        INSERT INTO public.members (member_id, full_name, personal_email, location_id)
        VALUES (%s, %s, %s, %s)
        RETURNING member_id
    """, (member_id, full_name, personal_email, location_id))
    return member_id

def insert_users(cur, location_id):
    user_id = random_uuid()
    username = fake.user_name()
    email = fake.email()
    password_hash = random_password_hash()
    full_name = fake.name()
    date_joined = random_timestamp()
    last_login = random_timestamp(date_joined)
    cur.execute("""
        INSERT INTO public.users (user_id, username, email, password_hash, full_name, date_joined, last_login, location_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING user_id
    """, (user_id, username, email, password_hash, full_name, date_joined, last_login, location_id))
    return user_id

def insert_applications(cur):
    app_id = random_uuid()
    app_name = fake.domain_word()
    app_type = random_enum([
        'Web', 'API', 'Database', 'Worker', 'Cache', 'Mobile', 'Desktop', 'Analytics', 'Monitoring',
        'Messaging', 'Search', 'ML', 'IoT', 'Gateway', 'Proxy', 'LoadBalancer', 'Scheduler',
        'Reporting', 'Backup', 'Streaming'
    ])
    hosting_environment = random_enum(['Containerized', 'Virtual Machine', 'Bare Metal', 'Serverless', 'Unknown'])
    cur.execute("""
        INSERT INTO public.applications (app_id, app_name, app_type, hosting_environment)
        VALUES (%s, %s, %s, %s)
        RETURNING app_id
    """, (app_id, app_name, app_type, hosting_environment))
    return app_id

def insert_server_metrics(cur, server_id, location_id, timestamp):
    cpu_usage = round(random.uniform(0, 100), 2)
    memory_usage = round(random.uniform(0, 100), 2)
    disk_read_ops_per_sec = random.randint(0, 100)
    disk_write_ops_per_sec = random.randint(0, 100)
    network_in_bytes = random.randint(0, 1000000)
    network_out_bytes = random.randint(0, 1000000)
    uptime_in_mins = random.randint(0, 100000)
    latency_in_ms = round(random.uniform(0.5, 100), 3)
    disk_usage_percent = round(random.uniform(0, 100), 2)
    error_count = random.randint(0, 10)
    disk_read_throughput = random.randint(0, 1000000)
    disk_write_throughput = random.randint(0, 1000000)
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
    hourly_avg_cpu_usage = round(random.uniform(0, 100), 2)
    hourly_avg_memory_usage = round(random.uniform(0, 100), 2)
    peak_network_usage = random.randint(0, 1000000)
    peak_disk_usage = random.randint(0, 1000000)
    uptime_percentage = round(random.uniform(90, 100), 2)
    total_requests = random.randint(0, 100000)
    error_rate = round(random.uniform(0, 10), 2)
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

def insert_resource_allocation(cur, server_id, app_id, timestamp):
    workload_type = random_enum(['batch', 'realtime', 'interactive'])
    allocated_memory = random.randint(512, 65536)
    allocated_cpu = round(random.uniform(0.1, 64), 2)
    allocated_disk_space = random.randint(10, 1000)
    resource_tag = fake.word()
    utilization_percentage = round(random.uniform(0, 100), 2)
    autoscaling_enabled = random_bool()
    max_allocated_memory = allocated_memory + random.randint(0, 1024)
    max_allocated_cpu = allocated_cpu + round(random.uniform(0, 8), 2)
    max_allocated_disk_space = allocated_disk_space + random.randint(0, 100)
    actual_memory_usage = random.randint(0, allocated_memory)
    actual_cpu_usage = round(random.uniform(0, allocated_cpu), 2)
    actual_disk_usage = random.randint(0, allocated_disk_space)
    cost_per_hour = round(random.uniform(0.01, 10), 4)
    allocation_status = random_enum(['active', 'pending', 'deallocated'])
    cur.execute("""
        INSERT INTO public.resource_allocation (
            server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
            resource_tag, "timestamp", utilization_percentage, autoscaling_enabled, max_allocated_memory,
            max_allocated_cpu, max_allocated_disk_space, actual_memory_usage, actual_cpu_usage,
            actual_disk_usage, cost_per_hour, allocation_status
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
          resource_tag, timestamp, utilization_percentage, autoscaling_enabled, max_allocated_memory,
          max_allocated_cpu, max_allocated_disk_space, actual_memory_usage, actual_cpu_usage,
          actual_disk_usage, cost_per_hour, allocation_status))

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

def insert_alert_configuration(cur, server_id, timestamp, team_contact_email):
    alert_config_id = random_uuid()
    metric_name = random_enum(['cpu_usage', 'memory_usage', 'disk_usage_percent', 'network_in_bytes'])
    threshold_value = round(random.uniform(50, 100), 2)
    alert_frequency = random_interval()
    contact_email = team_contact_email
    alert_enabled = random_bool()
    alert_type = random_enum(['EMAIL', 'SMS', 'WEBHOOK', 'SLACK'])
    severity_level = random_enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
    cur.execute("""
        INSERT INTO public.alert_configuration (
            alert_config_id, server_id, metric_name, threshold_value, alert_frequency, contact_email,
            alert_enabled, alert_type, severity_level, "timestamp"
        ) VALUES (%s, %s, %s, %s, %s::interval, %s, %s, %s, %s, %s)
    """, (alert_config_id, server_id, metric_name, threshold_value, alert_frequency, contact_email,
          alert_enabled, alert_type, severity_level, timestamp))

def insert_cost_data(cur, server_id, timestamp, team_id):
    cost_per_hour = round(random.uniform(0.01, 10), 2)
    total_monthly_cost = round(cost_per_hour * 24 * 30, 2)
    cost_per_day = round(cost_per_hour * 24, 2)
    cost_type = random_enum(['compute', 'storage', 'network'])
    cost_adjustment = round(random.uniform(-5, 5), 2)
    cost_adjustment_reason = fake.sentence()
    cost_basis = random_enum(['on-demand', 'reserved', 'spot'])
    cur.execute("""
        INSERT INTO public.cost_data (
            server_id, "timestamp", cost_per_hour, total_monthly_cost, team_allocation, cost_per_day,
            cost_type, cost_adjustment, cost_adjustment_reason, cost_basis
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (server_id, timestamp, cost_per_hour, total_monthly_cost, team_id, cost_per_day,
          cost_type, cost_adjustment, cost_adjustment_reason, cost_basis))

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

# --- MAIN LOOP ---

def main():
    print("Enums created/verified.")

    member_insert_count = 0

    while True:
        with get_conn() as conn, conn.cursor() as cur:
            for _ in range(ROWS_PER_RUN):
                # 1. Insert a new member
                location_id = insert_location(cur)
                member_id = insert_members(cur, location_id)
                member_insert_count += 1

                # 2. Occasionally create a new team (every 5-10 member inserts)
                if member_insert_count == 1 or random.randint(5, 10) == 7:
                    # Use the most recent member as team lead
                    team_lead_id = member_id
                    team_id = random_uuid()
                    _, team_contact_email = insert_team_management(cur, location_id, team_lead_id, team_id=team_id)

                # 3. Insert into team_members (only if member_id not already present)
                cur.execute("SELECT 1 FROM public.team_members WHERE member_id = %s", (member_id,))
                already_in_team = cur.fetchone()
                if not already_in_team:
                    existing_team_id = get_random_team_id(cur)
                    if existing_team_id:
                        insert_team_members(cur, existing_team_id, member_id)

                # 4. Users
                user_id = insert_users(cur, location_id)
                # 5. Applications
                app_id = insert_applications(cur)
                # 6. Server Metrics
                server_id = random_uuid()
                timestamp = datetime.now()
                insert_server_metrics(cur, server_id, location_id, timestamp)
                # 7. Aggregated Metrics
                insert_aggregated_metrics(cur, server_id, timestamp)
                # 8. Alert History
                insert_alert_history(cur, server_id, timestamp)
                # 9. Application Logs
                log_id = insert_application_logs(cur, server_id, app_id, user_id, timestamp)
                # 10. Resource Allocation
                insert_resource_allocation(cur, server_id, app_id, timestamp)
                # 11. User Access Logs
                insert_user_access_logs(cur, user_id, server_id, timestamp)
                # 12. Alert Configuration
                if existing_team_id:
                    # Get contact email for this team
                    cur.execute("SELECT team_contact_email FROM public.team_management WHERE team_id = %s", (existing_team_id,))
                    row = cur.fetchone()
                    team_contact_email = row[0] if row else fake.company_email()
                    insert_alert_configuration(cur, server_id, timestamp, team_contact_email)
                # 13. Cost Data
                if existing_team_id:
                    insert_cost_data(cur, server_id, timestamp, existing_team_id)
                # 14. Incident Response Logs
                if existing_team_id:
                    incident_id = insert_incident_response_logs(cur, server_id, timestamp, existing_team_id)
                else:
                    incident_id = insert_incident_response_logs(cur, server_id, timestamp, None)
                # 15. Downtime Logs
                insert_downtime_logs(cur, server_id, timestamp, incident_id)
                # 16. Error Logs
                insert_error_logs(cur, server_id, timestamp, log_id, incident_id)
                # 17. Team Server Assignment
                if existing_team_id:
                    insert_team_server_assignment(cur, existing_team_id, server_id, timestamp)
            conn.commit()
            print(f"Inserted {ROWS_PER_RUN} rows for all tables at {datetime.now()}")

        time.sleep(SLEEP_SECONDS)

if __name__ == "__main__":
    main()