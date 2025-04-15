# How You Tested & Validated Data Integrity

- **Check constraints** ensure `resolved_at` is only set if `alert_status` is 'CLOSED'.
    - **Why?** Ensures **logical consistency** between the alert's status and resolution timestamp.
    - **How it works:** A **check constraint** ensures that the `resolved_at` field is only populated if the `alert_status` is 'CLOSED'. This prevents the situation where an alert is considered resolved, but the resolution timestamp is missing or incorrectly set.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        ALTER TABLE alert_history
        ADD CONSTRAINT check_resolved_at
        CHECK (resolved_at IS NOT NULL OR alert_status = 'OPEN');
        
        ```
        
- **Foreign key constraints** ensure alerts only reference valid servers.
    - **Why?** Prevents **orphaned alerts** by ensuring that each alert corresponds to a valid server in the `server_metrics` table.
    - **How it works:** A **foreign key constraint** enforces referential integrity between the `alert_history` table and the `server_metrics` table. This ensures that alerts can only be triggered by servers that exist in the system, avoiding data inconsistencies.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        ALTER TABLE alert_history
        ADD CONSTRAINT fk_server_id
        FOREIGN KEY (server_id) REFERENCES server_metrics(server_id);
        
        ```
        
- **Unit tests validate expected alert triggers and resolutions.**
    - **Why?** Guarantees that the system behaves correctly under different scenarios.
    - **How it works:** Implement **unit tests** for alerting logic to ensure alerts are triggered and resolved as expected. This includes testing that threshold breaches are correctly identified, alert statuses are updated correctly, and the `resolved_at` field is set only when the alert is closed.
    - **Example (Unit Test with Python):**
        
        ```python
        python
        CopyEdit
        import unittest
        from alert_system import trigger_alert, resolve_alert
        
        class TestAlertSystem(unittest.TestCase):
            def test_alert_triggered(self):
                # Simulate a server exceeding the CPU threshold
                alert = trigger_alert(server_id='s1a2b3', alert_type='CPU Overload', threshold_value=90)
                self.assertEqual(alert.alert_status, 'OPEN')
        
            def test_alert_resolved(self):
                # Simulate an alert resolution
                alert = resolve_alert(alert_id='alert123')
                self.assertEqual(alert.alert_status, 'CLOSED')
                self.assertIsNotNone(alert.resolved_at)
        
        if __name__ == '__main__':
            unittest.main()
        
        ```
        
- **Database consistency checks** ensure no duplicate or conflicting alerts.
    - **Why?** Prevents **duplicate alerts** or conflicting data that could lead to inaccurate reporting or responses.
    - **How it works:** Implement database queries to identify potential duplicate alerts based on criteria like `server_id`, `alert_type`, and `alert_triggered_at`. This ensures that each alert is unique and corresponds to a real issue, avoiding alert fatigue.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        SELECT server_id, alert_type, COUNT(*)
        FROM alert_history
        GROUP BY server_id, alert_type, alert_triggered_at
        HAVING COUNT(*) > 1;
        
        ```
        
        - This query identifies any **duplicate alerts** that may need further investigation or de-duplication.
- **Data type validation** ensures the right data types are stored in the right columns.
    - **Why?** Prevents **data corruption** and ensures that operations like arithmetic calculations and string comparisons behave as expected.
    - **How it works:** Set explicit **data type validation rules** for each column (e.g., `DECIMAL` for `threshold_value`, `VARCHAR` for `alert_type`, etc.) during schema creation and migration to enforce correct data entry.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE alert_history (
            alert_id UUID PRIMARY KEY,
            server_id UUID REFERENCES server_metrics(server_id),
            alert_type VARCHAR(50),
            threshold_value DECIMAL(10,2),
            alert_triggered_at TIMESTAMP,
            resolved_at TIMESTAMP,
            alert_status ENUM('OPEN', 'CLOSED')
        );
        
        ```
        
- **Audit logs** track manual modifications to alert records.
    - **Why?** Ensures **traceability** for any manual changes to alert data (such as status changes, timestamp edits, etc.).
    - **How it works:** Implement an **audit log table** to track any updates to the `alert_history` table. Each time an update is made to an alert record, a log is written to capture the modification details.
    - **Example:**
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE alert_history_audit (
            audit_id UUID PRIMARY KEY,
            alert_id UUID,
            changed_by VARCHAR(100),
            change_date TIMESTAMP,
            old_value TEXT,
            new_value TEXT
        );
        
        ```
        
        - Helps to ensure **transparency** and **compliance** by tracking changes and enabling rollback if needed.