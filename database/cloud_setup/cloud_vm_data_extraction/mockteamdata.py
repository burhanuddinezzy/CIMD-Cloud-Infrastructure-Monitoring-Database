# nano mockteamdata.py
# python3 mockteamdata.py

import psycopg2
import os
import random

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

DEPARTMENTS_AND_TEAMS = {
    "Engineering": [
        "Backend Team", "Frontend Team", "QA Automation Team", "DevOps Team"
    ],
    "Product": [
        "Product Management Team", "UX Research Team", "Product Analytics Team", "Product Operations Team"
    ],
    "Data": [
        "Data Engineering Team", "Data Science Team", "Machine Learning Team", "Data Platform Team"
    ],
    "Security": [
        "Application Security Team", "Cloud Security Team", "Compliance Team", "Incident Response Team"
    ],
    "IT": [
        "IT Support Team", "Network Operations Team", "IT Infrastructure Team", "Helpdesk Team"
    ],
    "Sales": [
        "Sales Operations Team", "Enterprise Sales Team", "Sales Enablement Team", "Account Management Team"
    ],
    "Marketing": [
        "Content Marketing Team", "Growth Marketing Team", "SEO Team", "Brand Marketing Team"
    ],
    "Customer Success": [
        "Customer Support Team", "Onboarding Team", "Customer Education Team", "Customer Advocacy Team"
    ],
    "HR": [
        "Recruiting Team", "HR Operations Team", "Employee Experience Team", "Compensation & Benefits Team"
    ],
    "Finance": [
        "FP&A Team", "Payroll Team", "Procurement Team", "Accounting Team"
    ]
}

TEAM_DESCRIPTIONS = {
    "Backend Team": "Builds and maintains server-side application logic and APIs.",
    "Frontend Team": "Develops user interfaces and ensures a seamless user experience.",
    "QA Automation Team": "Creates automated tests to ensure software quality.",
    "DevOps Team": "Manages CI/CD pipelines and infrastructure automation.",
    "Product Management Team": "Defines product vision and prioritizes features.",
    "UX Research Team": "Conducts user research to inform product design.",
    "Product Analytics Team": "Analyzes product usage data to guide decisions.",
    "Product Operations Team": "Supports product teams with process and tools.",
    "Data Engineering Team": "Designs and maintains data pipelines and warehouses.",
    "Data Science Team": "Builds models and extracts insights from data.",
    "Machine Learning Team": "Develops and deploys machine learning solutions.",
    "Data Platform Team": "Maintains scalable data infrastructure and tools.",
    "Application Security Team": "Ensures application security and compliance.",
    "Cloud Security Team": "Secures cloud infrastructure and services.",
    "Compliance Team": "Manages regulatory compliance and audits.",
    "Incident Response Team": "Responds to and investigates security incidents.",
    "IT Support Team": "Provides technical support to employees.",
    "Network Operations Team": "Monitors and manages network infrastructure.",
    "IT Infrastructure Team": "Maintains company hardware and core IT systems.",
    "Helpdesk Team": "Handles day-to-day IT issues and requests.",
    "Sales Operations Team": "Optimizes sales processes and tools.",
    "Enterprise Sales Team": "Manages relationships with large clients.",
    "Sales Enablement Team": "Equips sales teams with resources and training.",
    "Account Management Team": "Supports and grows existing customer accounts.",
    "Content Marketing Team": "Creates and manages marketing content.",
    "Growth Marketing Team": "Drives user acquisition and engagement.",
    "SEO Team": "Optimizes web presence for search engines.",
    "Brand Marketing Team": "Builds and maintains the company brand.",
    "Customer Support Team": "Assists customers with product issues.",
    "Onboarding Team": "Guides new customers through product setup.",
    "Customer Education Team": "Creates resources to educate customers.",
    "Customer Advocacy Team": "Builds relationships with loyal customers.",
    "Recruiting Team": "Sources and hires new talent.",
    "HR Operations Team": "Manages HR processes and employee records.",
    "Employee Experience Team": "Improves workplace culture and engagement.",
    "Compensation & Benefits Team": "Manages pay and benefits programs.",
    "FP&A Team": "Handles financial planning and analysis.",
    "Payroll Team": "Processes employee payroll and taxes.",
    "Procurement Team": "Manages purchasing and vendor relationships.",
    "Accounting Team": "Handles bookkeeping and financial reporting."
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def get_random_location_id(cur):
    cur.execute("SELECT location_id FROM public.location")
    locations = [row[0] for row in cur.fetchall()]
    return random.choice(locations) if locations else None

def insert_teams(cur):
    for department, teams in DEPARTMENTS_AND_TEAMS.items():
        for team in teams:
            description = TEAM_DESCRIPTIONS.get(team, "No description available.")
            location_id = get_random_location_id(cur)
            # Remove 'Team' from team name, lowercase, remove spaces
            team_email_name = team.replace("Team", "").replace(" ", "").lower()
            department_email = department.lower().replace(" ", "")
            team_contact_email = f"{team_email_name}@{department_email}cimd.com"
            cur.execute("""
                INSERT INTO public.team_management (team_name, department, team_description, team_office_location_id, team_contact_email)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (team_name) DO NOTHING
            """, (team, department, description, location_id, team_contact_email))

if __name__ == "__main__":
    with get_conn() as conn, conn.cursor() as cur:
        insert_teams(cur)
        conn.commit()
    print("Seeded teams table.")