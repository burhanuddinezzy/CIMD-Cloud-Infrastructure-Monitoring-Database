# Server Metrics

This table stores **performance and health metrics** for each server in a distributed infrastructure. It captures real-time data on CPU, memory, disk, network, uptime, latency, and database interactions. The purpose is to **monitor server health, detect anomalies, and optimize resource allocation**.

## **Data Points (Columns) – Purpose, Thought Process, and Data Type**

- **`server_id` (UUID)**
    - **Purpose**: Unique identifier for each server being monitored.
    - **How I Thought of Including It**: Needed a globally unique way to reference servers without relying on incremental IDs.
    - **Why I Thought of Including It**: Prevents ID conflicts and allows distributed systems to function smoothly.
    - **Data Type Used & Why**: `UUID` is globally unique, eliminating risks of duplication and avoiding sequential exposure of IDs.
- **`region` (VARCHAR(50))**
    - **Purpose**: Identifies the server’s geographical location (`us-east-1`, `eu-west-2`).
    - **How I Thought of Including It**: Essential for understanding performance variations across different locations.
    - **Why I Thought of Including It**: Helps in load balancing and detecting region-specific outages.
    - **Data Type Used & Why**: `VARCHAR(50)` to store readable region codes while keeping storage minimal.
- **`timestamp` (TIMESTAMP)**
    - **Purpose**: Stores the exact time when metrics were recorded.
    - **How I Thought of Including It**: Needed for historical trend analysis.
    - **Why I Thought of Including It**: Enables time-based queries and helps detect performance anomalies over time.
    - **Data Type Used & Why**: `TIMESTAMP` allows easy date-time filtering and sorting.
- **`cpu_usage` (FLOAT)**
    
    [CPU Handbook: Understanding the Central Processing Unit (CPU) and Its Role in Server Monitoring (1)](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/CPU%20Handbook%20Understanding%20the%20Central%20Processing%20%2019bead362d9380b8885cc5316c143619.md)
    
    - **Purpose**: Tracks CPU utilization percentage.
    - **How I Thought of Including It**: High CPU usage is a common indicator of performance bottlenecks.
    - **Why I Thought of Including It**: Helps in scaling decisions and workload balancing.
    - **Data Type Used & Why**: `FLOAT` is necessary as CPU usage involves decimal values.
- **`memory_usage` (FLOAT)**
    
    [**RAM Handbook: Understanding Memory and Its Role in Server Monitoring** (1)](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/RAM%20Handbook%20Understanding%20Memory%20and%20Its%20Role%20in%20%2019bead362d9380ce8529efa14aa7bc0c.md)
    
    - **Purpose**: Tracks memory consumption percentage.
    - **How I Thought of Including It**: Memory leaks can cause system crashes.
    - **Why I Thought of Including It**: Helps in early detection of excessive memory consumption.
    - **Data Type Used & Why**: `FLOAT` allows precise tracking of memory utilization.
- **`disk_read_ops_per_sec` (INTEGER)**
    
    [**Disk Read and Write Operations & SSDs: A Beginner's Guide** (1)](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/Disk%20Read%20and%20Write%20Operations%20&%20SSDs%20A%20Beginner's%2019bead362d93800880aae7ca7bd290ad.md)
    
    - **Purpose**: Measures the number of disk read operations per second.
    - **How I Thought of Including It**: High read operations may indicate performance issues.
    - **Why I Thought of Including It**: Useful for diagnosing slow disk performance and tuning storage.
    - **Data Type Used & Why**: `INTEGER` as disk reads are discrete counts.
- **`disk_write_ops_per_sec` (INTEGER)**
    - **Purpose**: Measures the number of disk write operations per second.
    - **How I Thought of Including It**: Unusual write spikes might indicate issues like excessive logging.
    - **Why I Thought of Including It**: Helps detect storage inefficiencies and optimize workloads.
    - **Data Type Used & Why**: `INTEGER` since writes are whole numbers.
- **`network_in_bytes` (BIGINT)**
    
    [**Network Traffic Handbook** (1)](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/Network%20Traffic%20Handbook%20(1)%2019bead362d9380d29e0fc0622aae0190.md)
    
    - **Purpose**: Captures the amount of incoming network traffic in bytes.
    - **How I Thought of Including It**: Sudden traffic surges might indicate DDoS attacks or data transfers.
    - **Why I Thought of Including It**: Helps in bandwidth management and security monitoring.
    - **Data Type Used & Why**: `BIGINT` because network traffic can be large in scale.
- **`network_out_bytes` (BIGINT)**
    - **Purpose**: Captures the amount of outgoing network traffic in bytes.
    - **How I Thought of Including It**: Helps track outbound data transfers for security and cost analysis.
    - **Why I Thought of Including It**: Prevents unexpected data leaks and supports traffic load balancing.
    - **Data Type Used & Why**: `BIGINT` to handle large-scale traffic values.
- **`uptime_in_mins` (INTEGER)**
    
    [**Server Metrics: Uptime, Latency, and DB query IO** (1)](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/Server%20Metrics%20Uptime,%20Latency,%20and%20DB%20query%20IO%20(1%2019bead362d9380f79734de0bd29ba6c0.md)
    
    - **Purpose**: Tracks how long a server has been running without downtime.
    - **How I Thought of Including It**: Important for reliability monitoring.
    - **Why I Thought of Including It**: Helps detect crashes, reboots, or hardware failures.
    - **Data Type Used & Why**: `INTEGER` as uptime is measured in whole minutes.
- **`latency_in_ms` (FLOAT)**
    
    [**Server Latency and Performance Monitoring Handbook**](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/Server%20Latency%20and%20Performance%20Monitoring%20Handbook%201a1ead362d938001b502d7c52cdb351e.md)
    
    - **Purpose**: Measures the time taken for a server to respond to requests (in milliseconds).
    - **How I Thought of Including It**: High latency signals slow response times.
    - **Why I Thought of Including It**: Helps in optimizing server response speeds.
    - **Data Type Used & Why**: `FLOAT` for precise tracking of latency.
- **`db_queries_per_sec` (INTEGER)**
    - **Purpose**: Tracks the number of database queries per second.
    - **How I Thought of Including It**: Database-heavy servers require optimization.
    - **Why I Thought of Including It**: Helps in query tuning and database scaling.
    - **Data Type Used & Why**: `INTEGER` as queries per second are whole numbers.
- **`disk_usage_percent` (FLOAT)**
    
    **Purpose**: Tracks disk usage as a percentage of total storage.
    
    **Why Include It?** Helps detect low disk space issues before they cause failures.
    
    **Data Type Used & Why**: `FLOAT` since disk usage is expressed in percentages.
    
- **`error_count` (INTEGER, Nullable)**
    
    **Purpose**: Tracks the number of errors logged for this server in the last recorded interval.
    
    **Why Include It?**: Helps correlate server performance with system errors.
    
    **Data Type Used & Why**: `INTEGER` since errors are discrete counts.
    
- **`disk_usage_percent` (FLOAT)**
    
    **Purpose**: Tracks disk usage as a percentage of total storage.
    
    **Why Include It?**: Helps detect low disk space issues before they cause failures.
    
    **Data Type & Why**: `FLOAT` because disk usage is expressed as a percentage.
    
- **`disk_read_throughput` (BIGINT)**
    
    **Purpose**: Tracks the throughput of disk read operations in bytes per second.
    
    **Why Include It?**: Measures how much data is being read from disk, which is helpful to understand disk load and performance during read-intensive operations.
    
    **Data Type & Why**: `BIGINT` to accommodate large values representing throughput in bytes.
    
- **`disk_write_throughput` (BIGINT)**
    
    **Purpose**: Tracks the throughput of disk write operations in bytes per second.
    
    **Why Include It?**: Measures how much data is being written to disk, which helps monitor disk performance during write-heavy workloads.
    
    **Data Type & Why**: `BIGINT` to accommodate large values representing throughput in bytes.
    

[**How `server_metrics` Interacts with Other Tables**](Server%20Metrics%2019bead362d93807788d0f64ed32e2552/How%20server_metrics%20Interacts%20with%20Other%20Tables%2019bead362d9380c49240e9be9398e3bd.md)

- Examples of Stored Data
    
    
    | **`server_id`**  | **`region`**  | **`timestamp`**  | `cpu_usage` | `memory_usage` | **`disk_read_ops_per_sec`** | **`disk_write_ops_per_sec`** | **`network_in_bytes`** | **`network_out_bytes`** | **`uptime_in_mins`**  | **`latency_in_ms`**  | **`db_queries_per_sec`**  |
    | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
    | `a1b2c3` | us-east-1 | 2024-01-30 12:34:56 | 78.5 | 65.3 | 240 | 315 | 56789012 | 43210987 | 10320 | 12.5 | 500 |
    | `d4e5f6` | eu-west-2 | 2024-01-30 12:35:56 | 45.3 | 50.8 | 180 | 290 | 46872341 | 39012345 | 20430 | 9.8 | 420 |



## Dive Into Details

- [**How `server_metrics` Interacts with Other Tables**](How%20server_metrics%20Interacts%20with%20Other%20Tables.md)
- [**What Queries Would Be Used?**](What%20Queries%20Would%20Be%20Used.md)
- [**Alternative Approaches**](Alternative%20Approaches.md)
- [**Performance Considerations & Scalability**](Performance%20Considerations%20&%20Scalability.md)
- [**Query Optimization Techniques**](Query%20Optimization%20Techniques.md)
- [**Handling Large-Scale Data**](Handling%20Large-Scale%20Data.md)
- [**Data Retention & Cleanup**](Data%20Retention%20&%20Cleanup.md)
- [**Security & Compliance**](Security%20&%20Compliance.md)
- [**Alerting & Automation**](Alerting%20&%20Automation.md)
- [**How You Tested & Validated Data Integrity**](How%20You%20Tested%20&%20Validated%20Data%20Integrity.md)
- [**Thought Process Behind Decisions**](Thought%20Process%20Behind%20Decisions.md)
