# What Queries Would Be Used?

1. **Find all alert configurations for a specific server**
    
    This query retrieves all alert configurations associated with a particular server, providing insight into the thresholds and alert settings for that server.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE server_id = 'srv-123';
    
    ```
    
2. **Get alerts for a specific metric type across all servers**
    
    This query fetches all alert configurations for a specific metric type (e.g., CPU usage), regardless of which server it is configured on. It’s useful for identifying all servers under a particular metric's threshold monitoring.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE metric_name = 'CPU Usage';
    
    ```
    
3. **Find all alerts sent to a specific contact email**
    
    This query returns all alert configurations where a specific email is listed to receive notifications, useful for reviewing all alerts assigned to a particular team or individual.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE contact_email = 'ops-team@example.com';
    
    ```
    
4. **Find all alerts triggered by a specific threshold value**
    
    This query identifies all alert configurations where a threshold value is set to a specific amount (e.g., all alerts with a CPU usage threshold of `90%`).
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE threshold_value = 90.0;
    
    ```
    
5. **Get the alert frequency for a specific server and metric**
    
    This query retrieves the frequency at which alerts are triggered for a specific server and metric type, helping administrators understand the alerting intervals for critical metrics.
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, metric_name, alert_frequency
    FROM alerts_configuration
    WHERE server_id = 'srv-123' AND metric_name = 'Memory Usage';
    
    ```
    
6. **Retrieve the alert configuration for a specific server, metric, and threshold value**
    
    This query pulls specific alert configurations when a server has multiple metrics and threshold combinations, helping narrow down the exact setup for monitoring.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE server_id = 'srv-123' AND metric_name = 'Disk I/O' AND threshold_value = 80.0;
    
    ```
    
7. **Find servers with critical alert configurations**
    
    This query identifies all servers with configured alerts that are set to trigger for critical thresholds (e.g., CPU > 90%). It helps prioritize servers that might need urgent monitoring or intervention.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE threshold_value > 90.0;
    
    ```
    
8. **Get a list of all alerts triggered within a specific date range**
    
    If you store timestamps for when the alert configuration was created or modified, this query will retrieve configurations updated within a given period, useful for reviewing recent setup changes.
    
    ```sql
    sql
    CopyEdit
    SELECT * FROM alerts_configuration
    WHERE created_at BETWEEN '2024-01-01' AND '2024-01-31';
    
    ```
    
9. **Check for duplicate alert configurations (same metric, threshold, and email)**
    
    This query helps find duplicate configurations that may have been unintentionally set up, allowing for better alert management.
    
    ```sql
    sql
    CopyEdit
    SELECT server_id, metric_name, threshold_value, contact_email, COUNT(*)
    FROM alerts_configuration
    GROUP BY server_id, metric_name, threshold_value, contact_email
    HAVING COUNT(*) > 1;
    
    ```
    
10. **Get servers with no alert configurations for critical metrics**
    
    This query identifies servers that might lack alert configurations for critical metrics (e.g., CPU or memory usage), helping to ensure that all servers are being adequately monitored.
    
    ```sql
    sql
    CopyEdit
    SELECT server_id
    FROM servers
    WHERE server_id NOT IN (SELECT server_id FROM alerts_configuration WHERE metric_name IN ('CPU Usage', 'Memory Usage'));
    
    ```
    

These queries help ensure that administrators can retrieve relevant data about alert configurations for specific servers, metrics, or contact emails, facilitating **effective monitoring** and **quick response** to potential system issues.