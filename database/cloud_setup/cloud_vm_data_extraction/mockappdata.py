# ALREADY RAN
# on the VM, script is name mockappdata.py
'''
nano mockappdata.py
python3 mockappdata.py (run once to insert all applications)
'''
import random
import psycopg2
import os

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def insert_all_applications(cur):
    applications = [
        # (app_id, app_name, app_type, hosting_environment)
        ("b67ff998-7b7e-456f-90e5-03a07f94a33b", "Slack", "Messaging", "Containerized"),
        ("baa931bb-4052-4566-8969-ebcff9ea8d69", "Zoom", "Video Conferencing", "Virtual Machine"),
        ("ab892203-542d-47dd-a9fe-8767af263ff7", "Microsoft Teams", "Collaboration", "Containerized"),
        ("25c8a99a-2c24-4a44-9dbf-3b568b2b66a1", "Google Drive", "Cloud Storage", "Serverless"),
        ("2476e9c3-946d-42ac-a6d7-7d5883cf5a11", "Dropbox", "Cloud Storage", "Virtual Machine"),
        ("f0e08019-3527-4b65-b35b-87e2c3aa8acf", "Box", "Cloud Storage", "Bare Metal"),
        ("c9498bb1-3ec2-41c8-b28d-6014915303d1", "Miro", "Collaboration", "Containerized"),
        ("e89e66dd-6613-487b-9e93-9cb1cc43a226", "Figma", "Design", "Containerized"),
        ("cc79f84d-0999-4d33-817b-10390a0386e6", "Jira", "Project Management", "Virtual Machine"),
        ("70e003b9-0211-4134-9485-59481f0edd41", "Trello", "Project Management", "Serverless"),
        ("b0dd3363-5806-4752-98ea-34870ba3a70f", "Asana", "Project Management", "Containerized"),
        ("f0e847ea-eef5-40d4-88d1-c42f3ec1650e", "Monday.com", "Project Management", "Containerized"),
        ("6c77ea9d-dc7e-4303-90dd-927acf66423c", "Notion", "Knowledge Base", "Virtual Machine"),
        ("2688b956-c22c-46f9-9819-92d6fe7a8bd9", "Confluence", "Knowledge Base", "Bare Metal"),
        ("48bb85b8-ef9f-4429-b512-afb3c49efea9", "GitHub", "Source Control", "Containerized"),
        ("9b349997-6c3a-46fd-a01e-4b80ec407c41", "Bitbucket", "Source Control", "Virtual Machine"),
        ("76a97d50-3d39-4868-b6e9-7b00d1a570e4", "CircleCI", "CI/CD", "Containerized"),
        ("07c85a94-4f2d-427d-a6e1-ae1f07775c53", "Jenkins", "CI/CD", "Bare Metal"),
        ("a76318ab-9c3e-4c79-b32c-b5f813170764", "Azure DevOps", "CI/CD", "Serverless"),
        ("08cd62d4-e0ad-4cfe-ad21-f3c45754ef4b", "Docker", "Containerization", "Bare Metal"),
        ("87490c0a-59a8-45ab-a95f-9c84c3ef4f50", "Kubernetes", "Container Orchestration", "Bare Metal"),
        ("14a613b9-eba1-4fd4-a5d5-902b10ccba01", "Datadog", "Monitoring", "Containerized"),
        ("f12655d9-cb2a-4e53-8b16-45d71051110f", "PagerDuty", "Incident Management", "Serverless"),
        ("78f91594-bcc0-45a3-8b0f-6dce0880a1bd", "Splunk", "Log Management", "Virtual Machine"),
        ("03800471-39cf-4293-b7ef-beca6f13c448", "Grafana", "Monitoring", "Containerized"),
        ("1cf9da55-bd7f-45b1-b28f-dd079c5e13fb", "Prometheus", "Monitoring", "Bare Metal"),
        ("ec8a6629-9e2f-4955-8a26-ef2c14adc5be", "Kibana", "Log Management", "Virtual Machine"),
        ("5b974b78-a961-45f4-8f2b-fb5e5ab0f9ce", "Elasticsearch", "Log Management", "Bare Metal"),
        ("e6ab0c74-2f0d-4716-8691-3e975706ff09", "Sentry", "Error Tracking", "Containerized"),
        ("4cdfa4e8-bc8b-4832-9bc8-3c4d33319347", "AWS Lambda", "Serverless", "Serverless"),
        ("4155f5e5-5949-44b5-9877-fd5ab76f0d3a", "Google BigQuery", "Analytics", "Serverless"),
        ("8cf8407d-60a7-4097-b977-bcedf7d37f12", "Snowflake", "Data Warehouse", "Serverless"),
        ("0f88076d-ce65-4be4-86a1-9caba60c9a7c", "Airflow", "Workflow Orchestration", "Virtual Machine"),
        ("3a7e4521-6f4b-45bc-b4ec-ee75d28c4273", "Looker", "Business Intelligence", "Containerized"),
        ("46b65d7d-84f1-4b3c-8327-f498c016dfa3", "Power BI", "Business Intelligence", "Serverless"),
        ("e259168f-1577-4f20-ac3b-ef719f36b580", "Tableau", "Business Intelligence", "Virtual Machine"),
        ("8095f8f9-2ded-46f8-b8e2-de8c375fc154", "Okta", "Identity Management", "Containerized"),
        ("2157d7f6-9de2-40bd-bb38-7c0dea779047", "Cloudflare", "Security", "Serverless"),
        ("93d4af35-c724-4b01-83b8-ea57f787e91f", "ServiceNow", "ITSM", "Virtual Machine"),
        ("47a60be5-c39b-4fcb-883a-f479fb6c7fa7", "Salesforce", "CRM", "Serverless"),
        ("d6d6a5c5-b00b-4586-b2da-30196dc3d030", "Zendesk", "Customer Support", "Containerized"),
        ("6ce478c9-e59c-4dd5-9119-ea04538cbf14", "Workday", "HR", "Virtual Machine"),
        ("7cd91651-f513-4d81-9ce6-2f6952aac818", "HubSpot", "Marketing Automation", "Serverless"),
        ("b5adc66a-e15c-44ef-8b10-90169f239314", "Marketo", "Marketing Automation", "Virtual Machine"),
        ("c3d78c1d-0fde-4aee-b031-ecbe8571f658", "OneDrive", "Cloud Storage", "Serverless"),
    ]
    for app_id, app_name, app_type, hosting_environment in applications:
        cur.execute("""
            INSERT INTO public.applications (app_id, app_name, app_type, hosting_environment)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (app_id) DO NOTHING
        """, (app_id, app_name, app_type, hosting_environment))

if __name__ == "__main__":
    with get_conn() as conn, conn.cursor() as cur:
        insert_all_applications(cur)
        conn.commit()
    print("All applications inserted.")