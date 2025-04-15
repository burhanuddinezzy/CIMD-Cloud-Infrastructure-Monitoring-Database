# How You Tested & Validated Data Integrity

- **Ensuring logs are stored in the correct order by `log_timestamp`**: Maintaining the correct chronological order of logs is critical for debugging and incident response. To ensure this, I implemented consistency checks to verify that logs are inserted and retrieved in the correct sequence based on the `log_timestamp` field.
    - **Testing Process**: I ran queries to retrieve logs from the `application_logs` table and checked if `log_timestamp` values were sorted in ascending order. Additionally, I implemented **unit tests** in the application that insert logs and then validate that logs can be queried back in the correct order.
    - **Validation Method**: I implemented a check that ensures there are no gaps in the timestamps and that logs are being written in the expected order. This is particularly important in distributed systems where logs may be generated on different nodes.
    - **Example Query**:
        
        ```sql
        sql
        CopyEdit
        SELECT log_timestamp, COUNT(*)
        FROM application_logs
        GROUP BY log_timestamp
        ORDER BY log_timestamp;
        
        ```
        
        This query ensures that no records are missing or misordered and validates the integrity of timestamp data.
        
- **Validating that `log_level` only contains predefined values (`DEBUG`, `INFO`, etc.)**: Ensuring that the `log_level` field only contains valid values is necessary for consistency and for preventing errors in analysis and reporting. For this, I used constraints to enforce acceptable values for `log_level`.
    - **Testing Process**: I defined an **ENUM** type in PostgreSQL to ensure only valid values are allowed in the `log_level` column. I also ran test cases to insert invalid data and verified that the system correctly rejects these entries. Furthermore, I ran a **data integrity check** to verify that the `log_level` field was populated correctly for all records.
    - **Validation Method**: Before any log data is inserted, I check that the value being inserted falls within the allowable `ENUM` values. For example, if a log message has a value outside of `DEBUG`, `INFO`, `WARN`, `ERROR`, or `CRITICAL`, the system automatically rejects the log.
    - **Example Query**:
        
        ```sql
        sql
        CopyEdit
        SELECT DISTINCT log_level
        FROM application_logs
        WHERE log_level NOT IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL');
        
        ```
        
        This query helps identify any entries that have invalid `log_level` values, if they exist.
        
- **Testing queries on large datasets to ensure indexing strategies work effectively**: With large-scale data, it's critical that queries perform well, especially when analyzing logs over long periods. To validate that our indexing strategies are working effectively, I tested queries that retrieved logs based on time (`log_timestamp`) and log level (`log_level`), ensuring the queries executed within an acceptable time frame.
    - **Testing Process**: I simulated real-world traffic and inserted large datasets into the `application_logs` table, ensuring that logs had varied timestamps and log levels. I then tested common queries, such as retrieving logs by time range or severity level, and compared execution times with and without indexes.
    - **Validation Method**: I monitored query performance with the **EXPLAIN** command in PostgreSQL to determine if the database was using the expected indexes efficiently. I ensured that queries that involve filtering on `log_timestamp` or `log_level` are optimized and perform as expected, even with large datasets.
    - **Example Query**:
        
        ```sql
        sql
        CopyEdit
        EXPLAIN ANALYZE
        SELECT * FROM application_logs
        WHERE log_level = 'ERROR'
        AND log_timestamp >= NOW() - INTERVAL '7 days';
        
        ```
        
        This helps visualize the query plan and validate that indexing on `log_timestamp` and `log_level` is being used properly to optimize the query.
        
- **Automated Data Integrity Monitoring**: In addition to manual testing, I set up automated monitoring systems to regularly verify the integrity of the log data. These systems run scheduled scripts that validate the uniqueness of `log_id`, ensure that `log_timestamp` follows the correct sequence, and check that `log_level` follows the correct ENUM constraints.
    - **Testing Process**: Automated checks run at regular intervals to verify the integrity of the logs, including detecting duplicate entries, missing timestamps, and invalid `log_level` values. Alerts are triggered if any integrity issues are detected.
    - **Example Automation**:
        - A **scheduled job** in PostgreSQL runs every hour to check for any missing or misordered timestamps in the `application_logs` table.
        - A **custom script** is executed to verify that there are no duplicate `log_id` values.
        - An **alerting system** is set up to notify the engineering team if any data integrity issue is detected in the logs.

By thoroughly testing data integrity and ensuring that all logs are stored correctly and efficiently, I can confidently guarantee that the log data will provide accurate insights for monitoring, alerting, and troubleshooting in production environments.