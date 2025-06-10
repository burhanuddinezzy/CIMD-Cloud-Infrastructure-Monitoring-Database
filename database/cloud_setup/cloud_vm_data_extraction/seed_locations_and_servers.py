# ALREADY RAN
# nano seed_locations.py
# python3 seed_locations.py (run once to insert all locations and servers)

import psycopg2
import os

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "postgres",
    "user": "postgres",
    "password": os.getenv("TELE_POSTGRES_PASS"),
}

LOCATION_DATA = [
    {
        "location_id": "11111111-1111-1111-1111-111111111111",
        "city": "New York",
        "country": "United States",
        "region": "NY",
        "lat": 40.7128,
        "lng": -74.0060
    },
    {
        "location_id": "22222222-2222-2222-2222-222222222222",
        "city": "San Francisco",
        "country": "United States",
        "region": "CA",
        "lat": 37.7749,
        "lng": -122.4194
    },
    {
        "location_id": "33333333-3333-3333-3333-333333333333",
        "city": "Chicago",
        "country": "United States",
        "region": "IL",
        "lat": 41.8781,
        "lng": -87.6298
    },
    {
        "location_id": "44444444-4444-4444-4444-444444444444",
        "city": "Houston",
        "country": "United States",
        "region": "TX",
        "lat": 29.7604,
        "lng": -95.3698
    },
    {
        "location_id": "55555555-5555-5555-5555-555555555555",
        "city": "Miami",
        "country": "United States",
        "region": "FL",
        "lat": 25.7617,
        "lng": -80.1918
    },
    {
        "location_id": "66666666-6666-6666-6666-666666666666",
        "city": "Seattle",
        "country": "United States",
        "region": "WA",
        "lat": 47.6062,
        "lng": -122.3321
    },
    {
        "location_id": "77777777-7777-7777-7777-777777777777",
        "city": "Boston",
        "country": "United States",
        "region": "MA",
        "lat": 42.3601,
        "lng": -71.0589
    },
    {
        "location_id": "88888888-8888-8888-8888-888888888888",
        "city": "Denver",
        "country": "United States",
        "region": "CO",
        "lat": 39.7392,
        "lng": -104.9903
    },
    {
        "location_id": "99999999-9999-9999-9999-999999999999",
        "city": "Atlanta",
        "country": "United States",
        "region": "GA",
        "lat": 33.7490,
        "lng": -84.3880
    },
    {
        "location_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "city": "Los Angeles",
        "country": "United States",
        "region": "CA",
        "lat": 34.0522,
        "lng": -118.2437
    }
]

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def insert_locations(cur):
    for loc in LOCATION_DATA:
        cur.execute("""
            INSERT INTO public.location (location_id, location_geom, country, region, location_name)
            VALUES (%s, ST_GeogFromText(%s), %s, %s, %s)
            ON CONFLICT (location_id) DO NOTHING
        """, (
            loc["location_id"],
            f"SRID=4326;POINT({loc['lng']} {loc['lat']})",
            loc["country"],
            loc["region"],
            loc["city"]
        ))

if __name__ == "__main__":
    with get_conn() as conn, conn.cursor() as cur:
        insert_locations(cur)
        conn.commit()
    print("Seeded locations table.")