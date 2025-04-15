# How You Tested & Validated Data Integrity

1. **Testing Access Logging Functionality**:
    - **Purpose**: To ensure that access logs are being captured accurately for all user interactions with servers and applications.
    - **How This Was Tested**:
        - Simulated user access from various IPs and access types (e.g., `READ`, `WRITE`, `EXECUTE`) and checked if logs were correctly recorded with the appropriate `user_id`, `server_id`, `access_type`, and `timestamp`.
        - Verified that edge cases like multiple users accessing the system simultaneously were handled properly.
        - Ensured that the access logs accurately reflect the actions performed on the system by checking the values of the `log_message`, `access_ip`, and `access_type` columns.
        - **Example**: Simulated a user access attempt with the following:
            
            ```sql
            sql
            CopyEdit
            INSERT INTO user_access_logs (access_id, user_id, server_id, access_type, timestamp, access_ip)
            VALUES (uuid_generate_v4(), 'usr123', 'srv456', 'READ', '2025-02-17 12:30:00+00', '192.168.0.1');
            
            ```
            
    - **Why This Is Important**: Ensures that logs are captured in a way that allows for accurate tracking of all user access events, essential for security and auditing purposes.
2. **Cross-Referencing Logs with Other Tables**:
    - **Purpose**: To validate that the data in the `user_access_logs` table is consistent with other related tables, ensuring integrity across the system.
    - **How This Was Tested**:
        - **Cross-Referencing with `error_logs`**: Checked if any user access events that resulted in errors were properly logged in both the `user_access_logs` and `error_logs` tables.
        - **Cross-Referencing with `alert_history`**: Ensured that any access events which triggered alerts (e.g., multiple failed login attempts) were properly logged in the `alert_history` table and that the data was consistent between tables.
        - **Example**:
            
            ```sql
            sql
            CopyEdit
            SELECT ual.access_id, ual.user_id, al.alert_id
            FROM user_access_logs ual
            JOIN alert_history al ON ual.user_id = al.user_id
            WHERE ual.timestamp > al.timestamp;
            
            ```
            
    - **Why This Is Important**: Ensures that different logs across the system are synchronized and that no logs are missing or inconsistent between critical tables.
3. **Validating Timestamp Precision**:
    - **Purpose**: To ensure that timestamps in the `user_access_logs` table are recorded with the correct precision and that no discrepancies exist between different time sources.
    - **How This Was Tested**:
        - **Comparing with Server Logs**: Compared the `timestamp` field in `user_access_logs` against actual server logs to ensure the logs in the database reflect the exact time of the user’s access event.
        - **Test Scenario**: Accessed the application and cross-checked the timestamp from the `user_access_logs` table with the log data from the server (e.g., `/var/log/auth.log` on a Linux server).
        - **Example**:
            
            ```sql
            sql
            CopyEdit
            SELECT access_id, timestamp
            FROM user_access_logs
            WHERE user_id = 'usr123'
            AND timestamp BETWEEN '2025-02-17 00:00:00' AND '2025-02-17 23:59:59';
            
            ```
            
    - **Why This Is Important**: Accurate timestamps are crucial for the integrity of access logs, especially for troubleshooting, security audits, and compliance purposes. Discrepancies in timestamps could lead to missed incidents or confusion during investigations.
4. **Verifying Data Completeness**:
    - **Purpose**: To ensure that all required fields (e.g., `user_id`, `server_id`, `timestamp`, `access_type`) are present and filled in every access log entry.
    - **How This Was Tested**:
        - Ran queries to check for any missing or null values in the important fields of the `user_access_logs` table.
        - **Example**:
            
            ```sql
            sql
            CopyEdit
            SELECT COUNT(*)
            FROM user_access_logs
            WHERE user_id IS NULL OR server_id IS NULL OR timestamp IS NULL OR access_type IS NULL;
            
            ```
            
    - **Why This Is Important**: Ensures that every access log entry contains complete and accurate data, making the logs reliable for analysis and audit.
5. **Testing for Duplicate Logs**:
    - **Purpose**: To make sure no duplicate access logs are created for the same event, ensuring data integrity.
    - **How This Was Tested**:
        - Ran queries to detect any duplicate records based on `user_id`, `server_id`, and `timestamp`.
        - **Example**:
            
            ```sql
            sql
            CopyEdit
            SELECT user_id, server_id, timestamp, COUNT(*)
            FROM user_access_logs
            GROUP BY user_id, server_id, timestamp
            HAVING COUNT(*) > 1;
            
            ```
            
    - **Why This Is Important**: Duplicate logs could lead to skewed data and potentially inaccurate reporting or analysis. Preventing duplicates ensures the logs are reliable.

By using these validation techniques, you can ensure the data integrity of the `user_access_logs` table and ensure it functions correctly within the overall logging and monitoring framework.