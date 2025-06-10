# nano mockserverdata.py
# python3 mockserverdata.py

import psycopg2
import os

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
    "d9a0b1c2-3b45-4078-d890-bcdef0123456"
]

SERVER_TO_LOCATION = {
    "550e8400-e29b-41d4-a716-446655440000": "11111111-1111-1111-1111-111111111111",
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

def insert_servers():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    for server_id in SERVER_IDS:
        location_id = SERVER_TO_LOCATION[server_id]
        cur.execute("""
            INSERT INTO public.server (server_id, location_id)
            VALUES (%s, %s)
            ON CONFLICT (server_id) DO NOTHING
        """, (server_id, location_id))
    conn.commit()
    cur.close()
    conn.close()
    print("Inserted all servers into the server table.")

if __name__ == "__main__":
    insert_servers()