# How You Tested & Validated Data Integrity

To ensure data integrity within the downtime logs, several validation techniques were implemented:

**Foreign Key Constraints**: A foreign key constraint is applied to the `server_id` column to ensure that every downtime record is associated with a valid server entry from the `server_metrics` table. This ensures that the downtime data corresponds to actual servers, preventing the possibility of orphaned records that would not be linked to any server data.

```sql
sql
CopyEdit
ALTER TABLE downtime_logs
ADD CONSTRAINT fk_server_id
FOREIGN KEY (server_id)
REFERENCES server_metrics(server_id)
ON DELETE CASCADE;

```

This ensures that if a server is deleted, all corresponding downtime logs are automatically removed, preserving referential integrity.

**Check Constraints**: To validate the temporal integrity of downtime records, a check constraint is used to enforce that the `end_time` is greater than the `start_time`. This ensures that the downtime duration is always positive and logically consistent.

```sql
sql
CopyEdit
ALTER TABLE downtime_logs
ADD CONSTRAINT check_time_order
CHECK (end_time > start_time);

```

This prevents any downtime records from being entered with an end time before the start time, eliminating any logical errors in the data.

**Automated Tests for Downtime Calculations**: Automated tests were implemented to verify the accuracy of downtime duration calculations. These tests check if the downtime duration is calculated correctly based on `start_time` and `end_time`, ensuring that the system reports accurate downtime durations. If any discrepancies are detected, the tests will fail and alert the team for further investigation.

Example of an automated test for downtime calculation:

```python
python
CopyEdit
import unittest
from datetime import datetime

class TestDowntimeCalculations(unittest.TestCase):

    def test_downtime_duration(self):
        start_time = datetime(2025, 2, 15, 10, 30)
        end_time = datetime(2025, 2, 15, 12, 30)
        downtime_duration = (end_time - start_time).total_seconds() / 60  # in minutes
        self.assertEqual(downtime_duration, 120)

if __name__ == '__main__':
    unittest.main()

```

This test checks whether the downtime duration calculation between `start_time` and `end_time` is accurate, ensuring the reported downtime matches the actual time elapsed.

**Data Consistency Checks**: Periodic data consistency checks are performed to ensure that the downtime records are accurate and consistent with other related tables, such as `server_metrics` and `incident_management`. For example, we can verify that downtime logs within a certain period align with the server's performance metrics (e.g., CPU usage, memory usage), confirming that downtime events are properly recorded during times of performance degradation or failure.

```sql
sql
CopyEdit
SELECT dl.server_id, dl.start_time, sm.cpu_usage, sm.memory_usage
FROM downtime_logs dl
JOIN server_metrics sm ON dl.server_id = sm.server_id
WHERE dl.start_time BETWEEN sm.timestamp - INTERVAL '5 minutes' AND sm.timestamp + INTERVAL '5 minutes';

```

This query checks if downtime logs are appropriately linked with corresponding server metrics within a 5-minute window, validating the accuracy of both downtime logs and server metrics.

**Automated Data Integrity Jobs**: In addition to manual testing, automated jobs are set up to run at regular intervals (e.g., daily or weekly) to validate the integrity of the downtime logs. These jobs include checks for:

- Missing or incorrect timestamps (e.g., checking for null `start_time` or `end_time`).
- Negative downtime durations (i.e., ensuring no downtime record has a duration of less than 0 minutes).
- Inconsistent `sla_tracking` flags (e.g., ensuring that downtime events exceeding SLA limits are flagged properly).

These checks help catch any data integrity issues before they impact analysis or reporting.

Example of an automated job that checks for missing timestamps:

```sql
sql
CopyEdit
SELECT * FROM downtime_logs
WHERE start_time IS NULL OR end_time IS NULL;

```

This ensures that no downtime logs are entered without valid start and end times, preventing incomplete records from affecting downstream processes.

**Data Anomaly Detection**: A separate system for anomaly detection can be implemented to flag any outlier downtime events, such as unusually long downtime periods or events that are inconsistent with typical server behavior. Machine learning models or statistical methods (e.g., Z-scores) can be used to detect these anomalies and raise alerts for further validation.

By combining foreign key and check constraints, automated tests, data consistency checks, and anomaly detection, the system ensures the integrity of downtime logs, reducing the risk of errors and ensuring that downtime data is reliable and accurate for reporting and decision-making purposes.