# nano mockfixeddata.py
# python3 mockfixeddata.py

import psycopg2
import os
import random
import uuid
from datetime import datetime, timedelta
from faker import Faker

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

def random_uuid():
    return str(uuid.uuid4())

def random_bool():
    return random.choice([True, False])

def random_enum(enum_list):
    return random.choice(enum_list)

def random_interval():
    return f"{random.randint(1, 24)} hours"

def random_timestamp(start=None, end=None):
    if not start:
        start = datetime.now() - timedelta(days=30)
    if not end:
        end = datetime.now()
    return fake.date_time_between(start_date=start, end_date=end)


# --- MEMBERS ---
def insert_members(cur, location_id):
    member_id = random_uuid()
    first_name = fake.first_name().lower()
    last_name = fake.last_name().lower()
    full_name = first_name + " " + last_name
    name_part = f"{first_name}.{last_name}"
    personal_email = f"{name_part}@membercimd.com"
    cur.execute("""
        INSERT INTO public.members (member_id, full_name, personal_email, location_id)
        VALUES (%s, %s, %s, %s)
        RETURNING member_id
    """, (member_id, full_name, personal_email, location_id))
    return member_id, name_part

# --- TEAM MEMBERS ---
def insert_team_members(cur, member_id, name_part, team_id):
    TEAM_ROLE_MAP = {
        "Backend Team": ["Backend Developer", "API Engineer", "Database Engineer", "Backend Lead"],
        "Frontend Team": ["Frontend Developer", "UI Engineer", "UX Designer", "Frontend Lead"],
        "QA Automation Team": ["QA Engineer", "Automation Engineer", "Test Analyst", "QA Lead"],
        "DevOps Team": ["DevOps Engineer", "CI/CD Engineer", "Cloud Engineer", "DevOps Lead"],
        "Product Management Team": ["Product Manager", "Product Owner", "Business Analyst", "Product Lead"],
        "UX Research Team": ["UX Researcher", "UX Designer", "UI Designer", "UX Lead"],
        "Product Analytics Team": ["Product Analyst", "Data Analyst", "Analytics Lead"],
        "Product Operations Team": ["Product Operations Specialist", "Product Ops Lead"],
        "Data Engineering Team": ["Data Engineer", "ETL Developer", "Data Platform Engineer", "Data Engineering Lead"],
        "Data Science Team": ["Data Scientist", "ML Engineer", "Research Scientist", "Data Science Lead"],
        "Machine Learning Team": ["ML Engineer", "ML Ops Engineer", "ML Researcher", "ML Lead"],
        "Data Platform Team": ["Data Platform Engineer", "Big Data Engineer", "Platform Lead"],
        "Application Security Team": ["AppSec Engineer", "Security Analyst", "Security Lead"],
        "Cloud Security Team": ["Cloud Security Engineer", "Security Architect", "Cloud Security Lead"],
        "Compliance Team": ["Compliance Analyst", "Compliance Manager", "Compliance Lead"],
        "Incident Response Team": ["Incident Responder", "Security Analyst", "IR Lead"],
        "IT Support Team": ["IT Support Specialist", "IT Technician", "IT Support Lead"],
        "Network Operations Team": ["Network Engineer", "Network Analyst", "Network Lead"],
        "IT Infrastructure Team": ["Infrastructure Engineer", "SysAdmin", "Infra Lead"],
        "Helpdesk Team": ["Helpdesk Specialist", "Helpdesk Lead"],
        "Sales Operations Team": ["Sales Ops Analyst", "Sales Ops Lead"],
        "Enterprise Sales Team": ["Enterprise Sales Rep", "Enterprise Sales Lead"],
        "Sales Enablement Team": ["Sales Enablement Specialist", "Sales Enablement Lead"],
        "Account Management Team": ["Account Manager", "Account Lead"],
        "Content Marketing Team": ["Content Marketer", "Content Strategist", "Content Lead"],
        "Growth Marketing Team": ["Growth Marketer", "Growth Lead"],
        "SEO Team": ["SEO Specialist", "SEO Lead"],
        "Brand Marketing Team": ["Brand Marketer", "Brand Lead"],
        "Customer Support Team": ["Support Specialist", "Support Lead"],
        "Onboarding Team": ["Onboarding Specialist", "Onboarding Lead"],
        "Customer Education Team": ["Customer Trainer", "Education Lead"],
        "Customer Advocacy Team": ["Advocacy Specialist", "Advocacy Lead"],
        "Recruiting Team": ["Recruiter", "Recruiting Lead"],
        "HR Operations Team": ["HR Ops Specialist", "HR Ops Lead"],
        "Employee Experience Team": ["Employee Experience Specialist", "Experience Lead"],
        "Compensation & Benefits Team": ["Compensation Analyst", "Benefits Specialist", "Comp & Ben Lead"],
        "FP&A Team": ["FP&A Analyst", "FP&A Lead"],
        "Payroll Team": ["Payroll Specialist", "Payroll Lead"],
        "Procurement Team": ["Procurement Specialist", "Procurement Lead"],
        "Accounting Team": ["Accountant", "Accounting Lead"],
    }

    cur.execute("SELECT team_name FROM public.team_management WHERE team_id = %s", (team_id,))
    row = cur.fetchone()
    if row:
        team_name = row[0]
        possible_roles = TEAM_ROLE_MAP.get(team_name, ["Team Member"])
    else:
        possible_roles = ["Team Member"]

    role = random.choice(possible_roles)
    team_domain = team_name.replace(" ", "").lower() if row else "team"
    email = f"{name_part}@{team_domain}.com"
    now = datetime.now()
    five_years_ago = now - timedelta(days=5*365)
    date_joined = fake.date_time_between(start_date=five_years_ago, end_date=now)
    cur.execute("""
        INSERT INTO public.team_members (member_id, team_id, role, email, date_joined)
        VALUES (%s, %s, %s, %s, %s)
    """, (member_id, team_id, role, email, date_joined))

# --- ALERT CONFIGURATION ---
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

# --- TEAM SERVER ASSIGNMENT ---
def insert_team_server_assignment(cur, team_id, server_id, timestamp):
    cur.execute("""
        INSERT INTO public.team_server_assignment (team_id, server_id, "timestamp")
        VALUES (%s, %s, %s)
    """, (team_id, server_id, timestamp))

if __name__ == "__main__":
    with get_conn() as conn, conn.cursor() as cur:
        # Get all location_ids, team_ids, server_ids
        cur.execute("SELECT location_id FROM public.location")
        location_ids = [row[0] for row in cur.fetchall()]
        cur.execute("SELECT team_id, team_contact_email FROM public.team_management")
        teams = cur.fetchall()
        # Pull server_ids from the server table (not server_metrics)
        cur.execute("SELECT server_id FROM public.server")
        server_ids = [row[0] for row in cur.fetchall()]

        # 1. Insert 200 members and assign to teams
        for _ in range(200):
            location_id = random.choice(location_ids)
            member_id, name_part = insert_members(cur, location_id)
            # Assign to a random team
            if teams:
                team_id, _ = random.choice(teams)
                insert_team_members(cur, member_id, name_part, team_id)

        # 2. Insert 1–3 alert_configurations per server, and team_server_assignment for each team/server
        now = datetime.now()
        for server_id in server_ids:
            num_alerts = random.randint(1, 3)
            for _ in range(num_alerts):
                # Pick a random team for contact email
                team_id, team_contact_email = random.choice(teams)
                insert_alert_configuration(cur, server_id, now, team_contact_email)
            # Assign all teams to this server (optional, or adjust as needed)
            for team_id, _ in teams:
                insert_team_server_assignment(cur, team_id, server_id, now)

        conn.commit()
    print("Seeded 200 members, team_members, 1–3 alert_configurations per server, and team_server_assignment.")