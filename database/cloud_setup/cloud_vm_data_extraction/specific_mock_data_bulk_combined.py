"""
Bulk insert script for 3 months of daily mock data for:
- error_logs (random 3-10 servers per day)
- resource_allocation (per app/server/day, with variance in actual usage columns)
- user_access_logs (random DevOps user, randomized fields)
- application_logs (random user from users table)

nano s_mock_bulk_c.py
"""

import random
import uuid
from datetime import datetime, timedelta, timezone
import psycopg2
from faker import Faker
import os

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

fake = Faker()

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def get_app_ids(cur):
    cur.execute("SELECT app_id FROM public.applications")
    return [row[0] for row in cur.fetchall()]

def get_user_ids(cur):
    cur.execute("SELECT user_id FROM public.users")
    return [row[0] for row in cur.fetchall()]

def get_devops_user_ids(cur):
    cur.execute("SELECT member_id FROM public.team_members WHERE LOWER(role) = 'devops'")
    return [row[0] for row in cur.fetchall()]

def get_server_ids(cur):
    cur.execute("SELECT server_id FROM public.server")
    return [row[0] for row in cur.fetchall()]

def get_app_usage_ranges(app_ids):
    ranges = []
    for _ in app_ids:
        cpu = (random.uniform(0.5, 8), random.uniform(8, 64))
        mem = (random.randint(1024, 8192), random.randint(8192, 65536))
        disk = (random.randint(10, 100), random.randint(100, 1000))
        ranges.append({"cpu": sorted(cpu), "mem": sorted(mem), "disk": sorted(disk)})
    return dict(zip(app_ids, ranges))

def bounded_random_walk(prev, minv, maxv, tolerance):
    low = max(minv, prev - tolerance)
    high = min(maxv, prev + tolerance)
    return round(random.uniform(low, high), 2)

def bounded_random_walk_int(prev, minv, maxv, tolerance):
    low = max(minv, prev - tolerance)
    high = min(maxv, prev + tolerance)
    return random.randint(int(low), int(high))

def insert_resource_allocation(cur, server_id, app_id, timestamp, usage_ranges, prev_vals=None):
    # Insert a row per app/server/day with varying actual usage
    workload_type = random.choice(['batch', 'realtime', 'interactive'])
    allocated_memory = random.randint(512, 65536)
    allocated_cpu = round(random.uniform(0.1, 64), 2)
    allocated_disk_space = random.randint(10, 1000)
    resource_tag = fake.word()
    utilization_percentage = round(random.uniform(0, 100), 2)
    autoscaling_enabled = random.choice([True, False])
    max_allocated_memory = allocated_memory + random.randint(0, 1024)
    max_allocated_cpu = allocated_cpu + round(random.uniform(0, 8), 2)
    max_allocated_disk_space = allocated_disk_space + random.randint(0, 100)
    cost_per_hour = round(random.uniform(0.01, 10), 4)
    allocation_status = random.choice(['active', 'pending', 'deallocated'])

    # Actual usage with variance
    if prev_vals is None:
        actual_cpu_usage = round(random.uniform(*usage_ranges["cpu"]), 2)
        actual_memory_usage = random.randint(*usage_ranges["mem"])
        actual_disk_usage = random.randint(*usage_ranges["disk"])
    else:
        actual_cpu_usage = bounded_random_walk(prev_vals["cpu"], usage_ranges["cpu"][0], usage_ranges["cpu"][1], 2)
        actual_memory_usage = bounded_random_walk_int(prev_vals["mem"], usage_ranges["mem"][0], usage_ranges["mem"][1], 512)
        actual_disk_usage = bounded_random_walk_int(prev_vals["disk"], usage_ranges["disk"][0], usage_ranges["disk"][1], 20)

    cur.execute("""
        INSERT INTO public.resource_allocation (
            server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
            resource_tag, "timestamp", utilization_percentage, autoscaling_enabled, max_allocated_memory,
            max_allocated_cpu, max_allocated_disk_space, actual_memory_usage, actual_cpu_usage,
            actual_disk_usage, cost_per_hour, allocation_status
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        server_id, app_id, workload_type, allocated_memory, allocated_cpu, allocated_disk_space,
        resource_tag, timestamp, utilization_percentage, autoscaling_enabled, max_allocated_memory,
        max_allocated_cpu, max_allocated_disk_space, actual_memory_usage, actual_cpu_usage,
        actual_disk_usage, cost_per_hour, allocation_status
    ))
    return {"cpu": actual_cpu_usage, "mem": actual_memory_usage, "disk": actual_disk_usage}

def insert_error_logs(cur, server_id, timestamp, log_id):
    error_id = str(uuid.uuid4())
    error_severity = random.choice(['INFO', 'WARNING', 'CRITICAL'])
    error_message = fake.sentence()
    resolved = random.choice([True, False])
    resolved_at = timestamp + timedelta(minutes=random.randint(1, 60)) if resolved else None
    error_source = random.choice(['APP', 'SYSTEM', 'SECURITY', 'NETWORK'])
    error_code = str(random.randint(1000, 9999))
    recovery_action = fake.sentence()
    cur.execute("""
        INSERT INTO public.error_logs (
            error_id, server_id, "timestamp", error_severity, error_message, resolved, resolved_at,
            error_source, error_code, recovery_action, log_id
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (error_id, server_id, timestamp, error_severity, error_message, resolved, resolved_at,
          error_source, error_code, recovery_action, log_id))

def insert_application_logs(cur, server_id, app_id, user_id, timestamp):
    log_id = str(uuid.uuid4())
    log_level = random.choice(['DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL'])
    log_timestamp = timestamp
    trace_id = str(uuid.uuid4())
    span_id = str(uuid.uuid4())
    source_ip = fake.ipv4_public()
    log_source = random.choice(['APP', 'DATABASE', 'SECURITY', 'SYSTEM'])
    cur.execute("""
        INSERT INTO public.application_logs (
            log_id, server_id, log_level, log_timestamp, trace_id, span_id, source_ip, user_id, log_source, app_id, "timestamp"
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (log_id, server_id, log_level, log_timestamp, trace_id, span_id, source_ip, user_id, log_source, app_id, timestamp))
    return log_id

def insert_user_access_logs(cur, user_id, server_id, timestamp):
    access_id = str(uuid.uuid4())
    access_type = random.choice(['READ', 'WRITE', 'DELETE', 'EXECUTE'])
    access_ip = fake.ipv4_public()
    user_agent = fake.user_agent()
    cur.execute("""
        INSERT INTO public.user_access_logs (
            access_id, user_id, server_id, access_type, "timestamp", access_ip, user_agent
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (access_id, user_id, server_id, access_type, timestamp, access_ip, user_agent))

def main():
    GMT_PLUS_4 = timezone(timedelta(hours=4))
    DAYS = 90  # 3 months
    start_date = (datetime.now(GMT_PLUS_4) - timedelta(days=DAYS)).replace(hour=12, minute=0, second=0, microsecond=0)
    end_date = datetime.now(GMT_PLUS_4).replace(hour=12, minute=0, second=0, microsecond=0)
    with get_conn() as conn, conn.cursor() as cur:
        print("DB connected", flush=True)
        # Delete existing data for the date range
        cur.execute("""
            DELETE FROM public.resource_allocation
            WHERE "timestamp" >= %s AND "timestamp" < %s
        """, (start_date, end_date))
        conn.commit()
        app_ids = get_app_ids(cur)
        user_ids = get_user_ids(cur)
        devops_user_ids = get_devops_user_ids(cur)
        server_ids = get_server_ids(cur)
        app_usage_ranges = get_app_usage_ranges(app_ids)
        prev_actual_usage = {(sid, aid): None for sid in server_ids for aid in app_ids}
        for day in range(DAYS):
            timestamp = (datetime.now(GMT_PLUS_4) - timedelta(days=(DAYS - day - 1))).replace(hour=12, minute=0, second=0, microsecond=0)
            # --- 1. ERROR LOGS: Only random 3-10 servers per day ---
            error_servers = random.sample(server_ids, random.randint(3, min(10, len(server_ids))))
            for server_id in error_servers:
                app_id = random.choice(app_ids)
                user_id = random.choice(user_ids)  # Use user_id from users table
                log_id = insert_application_logs(cur, server_id, app_id, user_id, timestamp)
                insert_error_logs(cur, server_id, timestamp, log_id)
            # --- 2. RESOURCE ALLOCATION: Per app/server/day, with variance in actual usage ---
            for server_id in server_ids:
                for app_id in app_ids:
                    prev_vals = prev_actual_usage[(server_id, app_id)]
                    prev_actual_usage[(server_id, app_id)] = insert_resource_allocation(
                        cur, server_id, app_id, timestamp, app_usage_ranges[app_id], prev_vals
                    )
            # --- 3. USER ACCESS LOGS: Use random DevOps user and randomize all fields ---
            for server_id in server_ids:
                if devops_user_ids:  # Only insert if there are DevOps users
                    user_id = random.choice(devops_user_ids)
                    insert_user_access_logs(cur, user_id, server_id, timestamp)
            print(f"Inserted all data for {timestamp.date()}", flush=True)
        conn.commit()
        print("Bulk insert complete!", flush=True)

if __name__ == "__main__":
    main()