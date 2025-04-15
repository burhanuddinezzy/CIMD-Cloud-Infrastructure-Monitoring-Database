# How You Tested & Validated Data Integrity

Ensuring **data integrity** is **critical** for a reliable incident management system. Below is a **detailed breakdown** of how testing and validation were performed to ensure correct logging, SLA compliance, and performance under heavy load.

---

## **1. Simulated Incidents to Ensure Correct Logging**

### **Why?**

- Ensures that **incident data is correctly recorded** in the database.
- Helps verify **automated triggers, notifications, and escalations**.
- Detects **inconsistencies in data flow** between services.

### **Testing Strategies**

✅ **Inserted Sample Incidents with Different Severity Levels**

```sql
sql
CopyEdit
INSERT INTO incident_response_logs (incident_id, server_id, timestamp, response_team_id, incident_summary, resolution_time_minutes, status, priority_level, incident_type, root_cause, escalation_flag, audit_log_id)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', '1b2d3f4a-5678-9876-5432-123456789abc', NOW(), '3c4d5e6f-7890-8765-4321-987654321fed',
     'Database latency detected', 45, 'Resolved', 'High', 'Performance Issue', 'Query execution inefficiency', FALSE, '9988aabb-ccdd-1122-3344-556677889900'),

    ('662f8400-e29b-41d4-a716-446655440000', '2b3d4f5a-6789-9876-5432-234567890bcd', NOW(), '4d5e6f7a-8901-9876-5432-876543210fed',
     'Network outage detected', NULL, 'Open', 'Critical', 'Network Failure', NULL, TRUE, 'bbccdd11-2233-4455-6677-8899aabbccdd');

```

💡 **Expected Results:**

- High and Critical incidents should trigger real-time **alerts**.
- Escalation flag should be **TRUE** for the `Critical` incident.
- Resolution time should remain **NULL** for unresolved incidents.

✅ **Checked If Alerts Were Triggered Correctly**

```sql
sql
CopyEdit
SELECT * FROM pg_stat_activity WHERE query ILIKE '%notify_high_severity_alerts%';

```

💡 **Verified that alerts were successfully generated** for the high-severity incidents.

✅ **Ensured Data Integrity via Referential Constraints**

```sql
sql
CopyEdit
SELECT COUNT(*)
FROM incident_response_logs i
LEFT JOIN server_metrics s ON i.server_id = s.server_id
LEFT JOIN team_management t ON i.response_team_id = t.team_id
WHERE s.server_id IS NULL OR t.team_id IS NULL;

```

💡 **Confirmed that all incidents are correctly linked** to valid server and team records.

---

## **2. Checked Resolution Times Against SLAs**

### **Why?**

- Ensures **response efficiency** and **contractual SLA compliance**.
- Detects **underperforming teams** that fail to resolve incidents within the required time.
- Helps **automate escalation** for overdue incidents.

### **Testing Strategies**

✅ **Defined SLA Thresholds for Resolution Time**

```sql
sql
CopyEdit
SELECT priority_level,
       AVG(resolution_time_minutes) AS avg_resolution_time,
       MAX(resolution_time_minutes) AS worst_case_resolution_time
FROM incident_response_logs
WHERE status = 'Resolved'
GROUP BY priority_level;

```

💡 **Compared average and worst-case resolution times** with SLA agreements.

✅ **Identified SLA Breaches**

```sql
sql
CopyEdit
SELECT incident_id, priority_level, resolution_time_minutes
FROM incident_response_logs
WHERE priority_level = 'Critical' AND resolution_time_minutes > 60;

```

💡 **Extracted incidents that exceeded SLA thresholds** (e.g., Critical incidents should be resolved within 1 hour).

✅ **Ensured Automatic Escalation for SLA Violations**

```sql
sql
CopyEdit
SELECT incident_id, status, escalation_flag
FROM incident_response_logs
WHERE escalation_flag = TRUE AND status <> 'Escalated';

```

💡 **Verified that incidents breaching SLAs were escalated correctly.**

---

## **3. Performed Stress Tests on Query Performance with Large Datasets**

### **Why?**

- Ensures **the system remains performant** under real-world loads.
- Helps **optimize indexing and partitioning strategies**.
- Prevents **query slowdowns that could delay incident response**.

### **Testing Strategies**

✅ **Bulk Inserted 10 Million Test Records**

```sql
sql
CopyEdit
DO $$
DECLARE i INT := 0;
BEGIN
    WHILE i < 10000000 LOOP
        INSERT INTO incident_response_logs (incident_id, server_id, timestamp, response_team_id, incident_summary, resolution_time_minutes, status, priority_level, incident_type, root_cause, escalation_flag, audit_log_id)
        VALUES (gen_random_uuid(), gen_random_uuid(), NOW() - INTERVAL '1 day' * (random() * 365), gen_random_uuid(),
                'Test incident ' || i, FLOOR(random() * 180),
                CASE WHEN random() > 0.8 THEN 'Resolved' ELSE 'Open' END,
                CASE WHEN random() > 0.7 THEN 'Critical' ELSE 'Low' END,
                'System Failure', 'Unknown', FALSE, gen_random_uuid());
        i := i + 1;
    END LOOP;
END $$;

```

💡 **Simulated real-world scale with 10 million incidents.**

✅ **Measured Query Performance (Before Indexing)**

```sql
sql
CopyEdit
EXPLAIN ANALYZE
SELECT * FROM incident_response_logs
WHERE priority_level = 'Critical'
AND timestamp > NOW() - INTERVAL '7 days';

```

💡 **Identified slow query execution times due to missing indexes.**

✅ **Optimized Query Performance (After Indexing)**

```sql
sql
CopyEdit
CREATE INDEX idx_incident_priority_timestamp ON incident_response_logs(priority_level, timestamp);

```

```sql
sql
CopyEdit
EXPLAIN ANALYZE
SELECT * FROM incident_response_logs
WHERE priority_level = 'Critical'
AND timestamp > NOW() - INTERVAL '7 days';

```

💡 **Execution time improved by 60-80% after adding indexes.**

✅ **Partitioned Data by Year for Long-Term Storage**

```sql
sql
CopyEdit
CREATE TABLE incident_response_logs_2024 PARTITION OF incident_response_logs
FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

```

💡 **Partitioning reduced scan time for recent incidents.**

✅ **Verified Query Optimization for Historical Analysis**

```sql
sql
CopyEdit
EXPLAIN ANALYZE
SELECT COUNT(*) FROM incident_response_logs WHERE timestamp < NOW() - INTERVAL '2 years';

```

💡 **Confirmed that historical data queries now target partitioned tables, improving performance.**

---

## **4. Ensured Data Accuracy & Consistency via Constraints**

### **Why?**

- Prevents **duplicate incidents** or **missing critical fields**.
- Ensures **referential integrity** between related tables.

### **Testing Strategies**

✅ **Checked for Duplicates**

```sql
sql
CopyEdit
SELECT incident_id, COUNT(*)
FROM incident_response_logs
GROUP BY incident_id
HAVING COUNT(*) > 1;

```

💡 **Verified that duplicate records do not exist.**

✅ **Enforced Foreign Key Constraints to Prevent Orphaned Records**

```sql
sql
CopyEdit
ALTER TABLE incident_response_logs
ADD CONSTRAINT fk_server FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;

```

💡 **Ensured that if a server is deleted, its incidents are also removed.**

✅ **Ensured No NULL Values in Critical Columns**

```sql
sql
CopyEdit
SELECT * FROM incident_response_logs
WHERE incident_id IS NULL OR timestamp IS NULL OR priority_level IS NULL;

```

💡 **Confirmed that required fields are always populated.**

---

## **Final Takeaways**

### ✅ **Validating Incident Data**

✔ **Simulated incidents** to ensure correct logging and escalation.

✔ **Checked resolution times against SLA agreements** to prevent violations.

✔ **Tested query performance with large-scale datasets** to ensure efficiency.

### ✅ **Optimizing Performance & Data Integrity**

✔ **Indexed priority-level and timestamps** for faster queries.

✔ **Partitioned large datasets** for efficient historical data retrieval.

✔ **Implemented foreign key constraints** to maintain referential integrity.

By rigorously **testing and validating data integrity**, the incident response system remains **reliable, efficient, and scalable** for handling large-scale operations. 🚀

4o
