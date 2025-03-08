# How You Tested & Validated Data Integrity

1. **Checked That Teams Only Manage Servers They Are Assigned To**:
    - **Purpose**: Ensure that the team-server relationship is maintained accurately and teams are not assigned to manage servers they are not responsible for.
    - **How I Tested It**:
        - I wrote **SQL queries** to check for teams with invalid server assignments. For example, I checked whether the `assigned_server_ids` field contained servers that weren't actually owned or managed by the team in the team management table.
        - Additionally, I created **test cases** where teams were intentionally misassigned servers, and I verified that the system prevented or flagged those cases.
        - I also used **integrity constraints** like foreign keys and validation rules to ensure data integrity in the team-server assignment process.
    - **Validation Outcome**:
        - This process ensured that no **cross-team server mismanagement** occurred and that each team only received notifications for servers they were responsible for.
        - It also helped ensure **correct access control** and accountability, preventing teams from accessing servers outside their responsibility.
2. **Simulated Alerts to Verify Notifications Go to the Correct Teams**:
    - **Purpose**: Ensure that alert notifications are routed to the right team members based on their assigned responsibilities, roles, and preferences.
    - **How I Tested It**:
        - I simulated several types of alerts (e.g., high CPU usage, low disk space, unauthorized access attempt) and triggered them for servers assigned to specific teams.
        - I tested both **alert frequency** (ensuring that alerts did not get triggered more than the defined frequency) and the **correct notification channels** (e.g., email, Slack, SMS) to verify that they aligned with team preferences.
        - To confirm correctness, I checked the **alert history** table to ensure the system logged the alerts and that they included the correct **team names**, **alert types**, and **contact emails**.
    - **Validation Outcome**:
        - This validation step helped ensure that **notifications** were delivered to the correct teams without errors or omissions. Any issues detected (e.g., wrong team receiving the alert or delayed notifications) were fixed by adjusting the configuration and testing again.
        - The **team assignment logic** was thoroughly validated, ensuring that when a new team was added or servers reassigned, alerts would always go to the correct team members.
3. **Ran Scalability Tests to Ensure Performance Under Large-Scale Usage**:
    - **Purpose**: Ensure that the system performs well when handling large datasets and scales effectively as the number of teams, servers, and alerts grows.
    - **How I Tested It**:
        - I conducted **stress testing** by adding a large number of teams (hundreds or thousands) and assigning them to hundreds of servers to simulate a real-world large-scale scenario.
        - I used **database optimization tools** (e.g., EXPLAIN plans in SQL) to monitor query performance and identify any slow or inefficient queries when accessing the `team_management`, `alerts_configuration`, and `server_metrics` tables.
        - I tested alert notification systems under heavy load by **simulating simultaneous alerts** for multiple teams and monitoring whether notifications were successfully sent without delay.
        - **Automated load tests** using tools like JMeter were also employed to simulate high numbers of alert triggers and ensure that the notification systems (email, SMS, etc.) could handle the volume.
    - **Validation Outcome**:
        - The system passed scalability tests by efficiently handling thousands of team-server relationships and alert notifications without performance degradation.
        - The database was able to handle high-frequency queries, and the system's overall response time was kept within an acceptable range, ensuring that it would perform well even as the infrastructure grew.
        - This test revealed that **indexing** certain columns (like `team_id`, `assigned_server_ids`, and `metric_name`) provided significant performance improvements, ensuring smooth scalability.
4. **Validated Data Consistency in Alerts and Incident Logs**:
    - **Purpose**: Ensure that alerts, incidents, and server assignments are consistently tracked across tables.
    - **How I Tested It**:
        - I ran simulations to create alerts, triggered incidents, and assigned teams to specific servers, then cross-checked the entries in both **alert_history** and **incident_response_logs** to confirm they aligned correctly.
        - This step involved checking that for each triggered alert, an associated **incident response log** was created and properly linked to the relevant server, team, and alert configuration.
        - I used **automated scripts** to compare records across tables and ensure that when a server's status changed (e.g., from "healthy" to "critical"), the relevant logs were updated in both the alerts and incident logs tables.
    - **Validation Outcome**:
        - This validation ensured that **data integrity** was maintained across tables, and there were no discrepancies or missing records in incident tracking or alert management.
5. **Tested Permissions and Role-Based Access Control (RBAC)**:
    - **Purpose**: Ensure that team members only have access to the data and actions they are authorized to perform, ensuring security and compliance.
    - **How I Tested It**:
        - I tested different user roles (e.g., team members, managers, system admins) by assigning various permissions to each and confirming that access control policies were enforced correctly.
        - **Mock users** were created for different roles, and I attempted to access or modify data outside the permissions for each role (e.g., attempting to modify a team's server assignment by an unauthorized user).
        - I also checked that **audit logs** captured any unauthorized access attempts and correctly recorded the actions taken by users with the appropriate permissions.
    - **Validation Outcome**:
        - The system's role-based access controls (RBAC) were validated as effective, ensuring that team members could only interact with the data relevant to their roles.
        - This testing step helped confirm that **data security** was maintained, and only authorized users could perform sensitive actions like editing team assignments or triggering critical alerts.

By thoroughly testing and validating data integrity through these processes, I ensured that the system could handle both the functional and performance demands of managing large-scale cloud infrastructure while maintaining a high level of security and compliance.