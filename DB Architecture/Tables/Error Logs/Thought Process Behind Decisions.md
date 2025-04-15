# Thought Process Behind Decisions

### **1. Why Store Error Logs in a Relational Database?**

**Why It Matters:** Error logs need to be queried efficiently, linked with related tables (e.g., Server Metrics, Incident Response Logs), and structured in a way that enables fast lookups for debugging and reporting.

**Decision:** Use **PostgreSQL** instead of NoSQL or a dedicated log storage system.

**Reasons:**

- **Joins with other tables** → Error logs must be linked to `server_id` (Server Metrics), `incident_id` (Incident Response), and `alert_id` (Alert History) for cross-referencing.
- **Structured querying** → SQL allows precise filtering (e.g., “show only `CRITICAL` errors in the last 24 hours”).
- **ACID compliance** → Ensures data consistency, preventing duplicate or orphaned logs.
- **Indexing on `timestamp` and `server_id`** → Enables fast lookups for time-based filtering and server-specific debugging.

**Alternatives Considered:**

- **NoSQL (MongoDB, DynamoDB)** → Good for unstructured logs but lacks efficient joins and SQL querying.
- **Time-Series Databases (InfluxDB, TimescaleDB)** → Optimized for high-volume metric logs but not ideal for structured error logs.
- **Log Aggregators (Elasticsearch, Splunk)** → Great for full-text searches but less efficient for relational queries.

PostgreSQL was chosen because error logs need **structured storage**, **efficient lookups**, and **cross-referencing with related tables**.

### **2. Why Include `error_severity` as an ENUM Instead of a Free-Text Field?**

**Why It Matters:** Errors need to be classified consistently for alerting, reporting, and prioritization.

**Decision:** Use an **ENUM (`INFO`, `WARNING`, `CRITICAL`)** instead of a free-text column.

**Reasons:**

- **Prevents inconsistent values** → Ensures that severity levels are standardized (instead of random values like `"High"`, `"Severe"`, `"Urgent"`).
- **Faster queries** → ENUM is **internally stored as an integer**, making filtering and sorting more efficient.
- **Optimized indexing** → Queries like `WHERE error_severity = 'CRITICAL'` perform better than on a free-text column.

**Alternatives Considered:**

- **Using a separate lookup table (`severity_levels` table)** → Provides flexibility but adds unnecessary complexity for just three fixed values.
- **Storing severity as a plain text column** → More prone to inconsistency and slower queries.

Using ENUM ensures **consistency, fast filtering, and efficient storage** for error severity levels.

### **3. Why Track Resolution Status with a `resolved` Boolean Instead of a Status Field?**

**Why It Matters:** Engineers need to quickly identify unresolved errors without complex filtering.

**Decision:** Use **a simple `BOOLEAN resolved` field** instead of a `status` column with multiple values.

**Reasons:**

- **Simplifies queries** → Instead of checking multiple values (`'open'`, `'in-progress'`, `'resolved'`), a simple `WHERE resolved = FALSE` suffices.
- **More efficient indexing** → Boolean indexing is faster than text-based status comparisons.
- **Pairs well with `resolved_at` timestamp** → If `resolved = TRUE`, the `resolved_at` timestamp stores when it was resolved.

**Alternatives Considered:**

- **Using a `status` column (`'open'`, `'in-progress'`, `'resolved'`)** → More flexibility but unnecessary complexity since most logs are either resolved or unresolved.
- **Tracking resolutions in a separate table** → Would be overkill for simple logging.

Using a **BOOLEAN `resolved` column** simplifies queries and ensures **fast lookups of active issues**.

### **4. Why Include a `resolved_at` Timestamp?**

**Why It Matters:** Tracking how quickly errors are resolved is key for **performance monitoring and SLA compliance**.

**Decision:** Add a `resolved_at` timestamp that is **NULL when the error is unresolved**.

**Reasons:**

- **Enables tracking of resolution times** → Can calculate average time to resolution (`AVG(resolved_at - timestamp)`).
- **Useful for SLAs and reporting** → Helps measure if issues are being resolved within expected timeframes.
- **Supports filtering for open vs. closed issues** → `WHERE resolved_at IS NULL` quickly finds unresolved errors.

**Alternatives Considered:**

- **Storing resolution time in a separate table** → Not necessary since each error has only one resolution timestamp.
- **Using a default timestamp (`1970-01-01`) for unresolved errors** → Confusing and leads to inaccurate reports.

By using **NULL values for unresolved errors**, queries remain **simple and efficient**.

### **5. Why Store `error_message` as TEXT Instead of VARCHAR?**

**Why It Matters:** Error messages vary greatly in length, and truncating them can result in lost debugging information.

**Decision:** Use **`TEXT` instead of `VARCHAR(n)`** for the `error_message` column.

**Reasons:**

- **Avoids truncation issues** → Some error messages are long (e.g., stack traces).
- **No performance difference** → In PostgreSQL, `TEXT` and `VARCHAR` are stored the same way.
- **More flexibility** → No need to predict maximum message length.

**Alternatives Considered:**

- **Using `VARCHAR(255)`** → Too restrictive; stack traces and error details can exceed this limit.
- **Storing error messages in a separate table** → Would improve indexing but adds unnecessary complexity for a single column.

Using **TEXT ensures that all error details are captured without truncation risks**.

### **6. Why Store Error Logs in the Same Database Instead of a Separate Logging DB?**

**Why It Matters:** Centralizing error logs alongside server metrics and alert history makes troubleshooting easier.

**Decision:** Store error logs **within the same PostgreSQL database** instead of using a separate logging system.

**Reasons:**

- **Allows easy joins with related tables** → Engineers can correlate error logs with server metrics, incidents, and alerts.
- **Simplifies data access** → No need for cross-database queries or separate logging infrastructure.
- **Ensures transactional consistency** → Error logs update in sync with application and server events.

**Alternatives Considered:**

- **Storing logs in a separate logging database** → Useful for high-scale logging, but unnecessary for a system with structured logs.
- **Using a dedicated log storage solution (Elasticsearch, Graylog, Splunk)** → Powerful for full-text search but less efficient for structured queries.

Keeping **error logs in the same database** enables **seamless debugging and correlation with other system events**.

### **Final Takeaways**

- **PostgreSQL was chosen over NoSQL and time-series databases** to support structured querying and joins.
- **Partitioning and indexing on `timestamp` and `server_id`** ensures **fast lookups** for recent errors.
- **ENUM was used for `error_severity`** to enforce standardization and improve query performance.
- **A `BOOLEAN resolved` field with a `resolved_at` timestamp** simplifies filtering and tracking resolution times.
- **TEXT was used for `error_message`** to handle **long, variable-length error logs** without truncation.
- **Error logs were kept in the same database** for **better correlation with metrics, alerts, and incidents**.

This thought process ensures **efficient error tracking, fast query performance, and seamless integration with other monitoring data** while maintaining **scalability and ease of debugging**.