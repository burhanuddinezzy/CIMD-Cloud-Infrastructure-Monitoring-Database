Absolutely! Since you’ve integrated PostGIS and your `server_metrics` table contains a `location_id` that ties to your new `location` table (which stores geospatial data using the `GEOGRAPHY(Point, 4326)` type), here are several **PostGIS queries** you can use to leverage that geospatial intelligence:

---

## 🔍 Basic Spatial Queries

### 1. **Find all servers within X km of a specific location**
```sql
SELECT sm.*
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id
WHERE ST_DWithin(
    l.location_geom,
    ST_MakePoint(-122.4194, 37.7749)::GEOGRAPHY,  -- Example: San Francisco coords
    50000  -- Distance in meters (50 km)
);
```

---

### 2. **Get the distance between each server and a central location**
```sql
SELECT sm.server_id, 
       ST_Distance(l.location_geom, ST_MakePoint(-74.0060, 40.7128)::GEOGRAPHY) AS distance_to_nyc
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id;
```

---

### 3. **Rank servers by distance to a point**
```sql
SELECT sm.server_id, 
       l.country,
       ST_Distance(l.location_geom, ST_MakePoint(-74.0060, 40.7128)::GEOGRAPHY) AS distance_to_nyc
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id
ORDER BY distance_to_nyc ASC;
```

---

## 🌎 Regional Insights

### 4. **Count how many servers are in each country**
```sql
SELECT l.country, COUNT(*) AS server_count
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id
GROUP BY l.country
ORDER BY server_count DESC;
```

---

### 5. **Find all servers in a specific bounding box (e.g., part of Europe)**
```sql
SELECT sm.*
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id
WHERE ST_Within(
    l.location_geom,
    ST_MakeEnvelope(-10.0, 35.0, 30.0, 60.0, 4326)::GEOGRAPHY  -- Rough bounding box over Europe
);
```

---

## 🧭 Server Clustering & Patterns

### 6. **Find clusters of servers (using KMeans style centroids for exploration)**
This is more advanced (requires an extension like `postgis_raster` or usage of centroid aggregations), but you can start simple:
```sql
SELECT ST_Centroid(ST_Collect(l.location_geom)) AS central_location
FROM server_metrics sm
JOIN location l ON sm.location_id = l.location_id;
```

---

### 7. **Find nearest neighbor server to each server**
```sql
SELECT a.server_id AS origin_server,
       b.server_id AS nearest_server,
       ST_Distance(al.location_geom, bl.location_geom) AS distance
FROM server_metrics a
JOIN location al ON a.location_id = al.location_id
JOIN server_metrics b ON a.server_id != b.server_id
JOIN location bl ON b.location_id = bl.location_id
WHERE ST_Distance(al.location_geom, bl.location_geom) = (
    SELECT MIN(ST_Distance(al.location_geom, bl2.location_geom))
    FROM server_metrics b2
    JOIN location bl2 ON b2.location_id = bl2.location_id
    WHERE a.server_id != b2.server_id
)
LIMIT 10;
```

---

If you’d like, I can also help you create **views** or **stored procedures** that encapsulate these queries for easy reuse or dashboards.

Want to explore regional incident patterns next using geospatial filters?
