"""
Bulk insert script for 3 months of daily data for slow-changing tables.
Each day inserts users, resource allocation, and cost data for all servers/apps/teams.
Run this ONCE to populate your DB for Power BI testing.
"""

import random
import uuid
from datetime import datetime, timedelta, timezone
import psycopg2
from faker import Faker
import os

# --- DB CONNECTION ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

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
    "d9a0b1c2-3b45-4078-d890-bcdef0123456",
    "550e8400-e29b-41d4-a716-446655440000"
]

team_id_list = [
    "4ce8654e-40a7-46e1-b6e4-d56de831723c",
    "a0f3be1d-b97b-4618-a300-47b061a39f45",
    "7ebf8290-7019-47cb-a579-55c9178068a4",
    "23c9fefc-821a-4b57-9a22-c08192941da2",
    "35173260-a13e-426a-989f-712bb11a4e27",
    "64300493-0ef8-43bf-a645-2eea83354b28",
    "58acc84d-2339-4e2b-bb43-c450d255d9d6",
    "b44aee22-ed35-43f2-9dd3-c4dada0849b2",
    "9e97dafc-c68c-41e7-9132-cb6276b73229",
    "f7cb1040-d6e8-4ec3-b020-08143ac40224",
    "6322eeae-34af-42e8-bd68-ec637a3a240a",
    "7c557c00-2ccc-4cdd-9764-261d7f76778d",
    "e5c329a0-8fb3-4538-8bdf-4e28fc686235",
    "7a27e6e9-1c2d-44ec-87cc-34d4f7bdd34e",
    "2747e9a1-575c-4fa3-973b-116e692dca0e",
    "a2680d1a-aeaf-4068-898e-d54f62b15701",
    "0fdcf004-cb51-41d4-ac1a-6dcd99af3a38",
    "0121e9ce-5132-49c1-a934-567f60ad101c",
    "b3f3e564-883d-4761-a7be-33a153a83cc6",
    "0441e939-30b9-4f1d-9c6c-7ca86b30cd2e",
    "f9b76396-74c0-40e0-92b1-c9da8a0853bc",
    "122f08d9-d140-4f6a-9b83-8d1fdb16d489",
    "aa1b5f9c-f52d-40ab-a91f-b209416671ec",
    "c7c0a721-38da-47f6-bff3-e43697d4f40b",
    "1937a92a-6738-41db-b858-5ff8c5394f44",
    "15ef2d87-df1b-49a9-9fac-d317623fd800",
    "6680064a-19ea-44f9-aa51-48b41d34d662",
    "7070a109-3733-4815-aae6-677ad03f35b8",
    "1daad880-3501-4c2b-85c9-54bb756532c5",
    "8147fa57-4f08-423f-98ea-544c55702dd2",
    "0f85996d-4e4e-488c-b365-17c3702508d9",
    "c6c292cf-8b32-4360-9cde-efdab4081edf",
    "c5e04a6a-5575-4660-af5f-99ebab81b65d",
    "dcf3ea98-ff89-4ab5-be2b-d6109f8391df",
    "0050bd28-dcd5-499b-8eef-2a7e5d060257",
    "64c06e2e-17a4-4c3c-9645-ea90b159b8fd",
    "60bec96e-0e18-4fb4-8d96-45dbb7d19121",
    "d1901175-c118-4989-88a9-da30775a4f22",
    "680b38db-fa5f-451b-99f5-120465d2d767",
    "87be4895-4362-4151-ba1b-9cef46dec44e"
]

app_ids = [
    "0f88076d-ce65-4be4-86a1-9caba60c9a7c",
    "b0dd3363-5806-4752-98ea-34870ba3a70f",
    "4cdfa4e8-bc8b-4832-9bc8-3c4d33319347",
    "a76318ab-9c3e-4c79-b32c-b5f813170764",
    "9b349997-6c3a-46fd-a01e-4b80ec407c41",
    "f0e08019-3527-4b65-b35b-87e2c3aa8acf",
    "76a97d50-3d39-4868-b6e9-7b00d1a570e4",
    "2157d7f6-9de2-40bd-bb38-7c0dea779047",
    "2688b956-c22c-46f9-9819-92d6fe7a8bd9",
    "14a613b9-eba1-4fd4-a5d5-902b10ccba01",
    "08cd62d4-e0ad-4cfe-ad21-f3c45754ef4b",
    "2476e9c3-946d-42ac-a6d7-7d5883cf5a11",
    "5b974b78-a961-45f4-8f2b-fb5e5ab0f9ce",
    "e89e66dd-6613-487b-9e93-9cb1cc43a226",
    "48bb85b8-ef9f-4429-b512-afb3c49efea9",
    "4155f5e5-5949-44b5-9877-fd5ab76f0d3a",
    "25c8a99a-2c24-4a44-9dbf-3b568b2b66a1",
    "03800471-39cf-4293-b7ef-beca6f13c448",
    "7cd91651-f513-4d81-9ce6-2f6952aac818",
    "07c85a94-4f2d-427d-a6e1-ae1f07775c53",
    "cc79f84d-0999-4d33-817b-10390a0386e6",
    "ec8a6629-9e2f-4955-8a26-ef2c14adc5be",
    "87490c0a-59a8-45ab-a95f-9c84c3ef4f50",
    "3a7e4521-6f4b-45bc-b4ec-ee75d28c4273",
    "b5adc66a-e15c-44ef-8b10-90169f239314",
    "ab892203-542d-47dd-a9fe-8767af263ff7",
    "c9498bb1-3ec2-41c8-b28d-6014915303d1",
    "f0e847ea-eef5-40d4-88d1-c42f3ec1650e",
    "6c77ea9d-dc7e-4303-90dd-927acf66423c",
    "8095f8f9-2ded-46f8-b8e2-de8c375fc154",
    "c3d78c1d-0fde-4aee-b031-ecbe8571f658",
    "f12655d9-cb2a-4e53-8b16-45d71051110f",
    "46b65d7d-84f1-4b3c-8327-f498c016dfa3",
    "1cf9da55-bd7f-45b1-b28f-dd079c5e13fb",
    "47a60be5-c39b-4fcb-883a-f479fb6c7fa7",
    "e6ab0c74-2f0d-4716-8691-3e975706ff09",
    "93d4af35-c724-4b01-83b8-ea57f787e91f",
    "b67ff998-7b7e-456f-90e5-03a07f94a33b",
    "8cf8407d-60a7-4097-b977-bcedf7d37f12",
    "78f91594-bcc0-45a3-8b0f-6dce0880a1bd",
    "e259168f-1577-4f20-ac3b-ef719f36b580",
    "70e003b9-0211-4134-9485-59481f0edd41",
    "6ce478c9-e59c-4dd5-9119-ea04538cbf14",
    "d6d6a5c5-b00b-4586-b2da-30196dc3d030",
    "baa931bb-4052-4566-8969-ebcff9ea8d69"
]

fake = Faker()
Faker.seed(42)
random.seed(42)

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def random_enum(enum_list):
    return random.choice(enum_list)

def random_bool():
    return random.choice([True, False])

def random_password_hash():
    return fake.sha256()

def random_ip():
    return fake.ipv4_public()

def random_timestamp(start=None, end=None):
    if not start:
        start = datetime.now() - timedelta(days=30)
    if not end:
        end = datetime.now()
    return fake.date_time_between(start_date=start, end_date=end)

def random_uuid():
    return str(uuid.uuid4())

def insert_users(cur, location_id, date_joined, last_login):
    user_id = random_uuid()
    username = fake.user_name()
    # Ensure unique email
    while True:
        email = f"{fake.first_name().lower()}.{fake.last_name().lower()}@usercimd.com"
        cur.execute("SELECT 1 FROM public.users WHERE email = %s", (email,))
        if not cur.fetchone():
            break
    password_hash = random_password_hash()
    full_name = fake.name()
    cur.execute("""
        INSERT INTO public.users (user_id, username, email, password_hash, full_name, date_joined, last_login, location_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING user_id
    """, (user_id, username, email, password_hash, full_name, date_joined, last_login, location_id))
    return user_id

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

def get_random_location_id(cur):
    cur.execute("SELECT location_id FROM public.location ORDER BY RANDOM() LIMIT 1;")
    row = cur.fetchone()
    return row[0] if row else None

def main():
    GMT_PLUS_4 = timezone(timedelta(hours=4))
    DAYS = 90  # 3 months
    with get_conn() as conn, conn.cursor() as cur:
        location_id = get_random_location_id(cur)
        for day in range(DAYS):
            timestamp = (datetime.now(GMT_PLUS_4) - timedelta(days=(DAYS - day - 1))).replace(hour=12, minute=0, second=0, microsecond=0)
            # Insert users (simulate a few new users per day)
            for _ in range(random.randint(3, 7)):
                date_joined = timestamp
                last_login = timestamp + timedelta(hours=random.randint(1, 23))
                insert_users(cur, location_id, date_joined, last_login)
            # Resource Allocation
            for server_id in SERVER_IDS:
                for app_id in app_ids:
                    insert_resource_allocation(cur, server_id, app_id, timestamp)
            # Cost Data
            for team_id in team_id_list:
                for server_id in SERVER_IDS:
                    insert_cost_data(cur, server_id, timestamp, team_id)
            print(f"Inserted data for {timestamp.date()}", flush=True)
        conn.commit()
        print("Bulk insert complete!", flush=True)

if __name__ == "__main__":
    main()