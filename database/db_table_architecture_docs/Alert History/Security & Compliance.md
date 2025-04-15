# Security & Compliance

- **Restrict access to alert data to incident management teams.**
    - **Why?** Only authorized personnel should view and manage alerts to prevent unauthorized access or tampering.
    - **How?**
        - Use **role-based access control (RBAC)** to grant specific permissions.
        - Restrict access to the `alert_history` table to only **admins and incident response teams**.
        - Create **database views** to show limited data for lower-privilege users.
    - **Example (PostgreSQL Role-Based Permissions):**
        
        ```sql
        sql
        CopyEdit
        CREATE ROLE incident_manager;
        GRANT SELECT, UPDATE, INSERT, DELETE ON alert_history TO incident_manager;
        
        CREATE ROLE read_only_user;
        GRANT SELECT ON alert_history TO read_only_user;
        
        ```
        
        - Ensures **only authorized teams** can take action on alerts.
- **Encrypt sensitive data like `server_id` to prevent unauthorized tracking.**
    - **Why?** A server’s identity could be exploited in targeted attacks.
    - **How?**
        - Use **PGP encryption** for storing `server_id` securely.
        - Encrypt data **at rest** using PostgreSQL’s `pgcrypto` extension.
        - Use **column-level encryption** instead of full-table encryption for efficiency.
    - **Example (Encrypting `server_id` with PGP):**
        
        ```sql
        sql
        CopyEdit
        CREATE EXTENSION pgcrypto;
        
        UPDATE alert_history
        SET server_id = PGP_SYM_ENCRYPT(server_id::TEXT, 'encryption_key');
        
        ```
        
        - Prevents **unauthorized tracking** of servers.
- **Use row-level security (RLS) for multi-tenant environments.**
    - **Why?** If multiple teams or organizations use the system, they should only see their own alerts.
    - **How?**
        - Implement **RLS policies** to filter data based on user roles or organizations.
    - **Example (Restrict Access to Alerts by Organization):**
        
        ```sql
        sql
        CopyEdit
        ALTER TABLE alert_history ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY org_isolation
        ON alert_history
        USING (current_user = org_admin);
        
        ```
        
        - Ensures **data isolation** across different teams or companies.
- **Audit logs to track who accessed or modified alert data.**
    - **Why?** Compliance standards (ISO 27001, SOC 2, GDPR) require tracking changes.
    - **How?**
        - Log **who, when, and what action** was taken on alerts.
        - Use **triggers** to log changes into an `audit_log` table.
    - **Example (Trigger-Based Audit Logging):**
        
        ```sql
        sql
        CopyEdit
        CREATE TABLE audit_log (
            log_id SERIAL PRIMARY KEY,
            action VARCHAR(10),
            table_name TEXT,
            modified_by TEXT,
            modified_at TIMESTAMP DEFAULT NOW()
        );
        
        CREATE OR REPLACE FUNCTION log_alert_changes()
        RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO audit_log (action, table_name, modified_by)
            VALUES (TG_OP, 'alert_history', current_user);
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        
        CREATE TRIGGER alert_audit
        AFTER INSERT OR UPDATE OR DELETE ON alert_history
        FOR EACH ROW EXECUTE FUNCTION log_alert_changes();
        
        ```
        
        - Ensures **full accountability** in alert modifications.
- **Mask sensitive alert details from unauthorized users.**
    - **Why?** Some alert details should be hidden from lower-privilege users.
    - **How?**
        - Use **PostgreSQL column masking** to partially hide data.
    - **Example (Masking `server_id` for Non-Admins):**
        
        ```sql
        sql
        CopyEdit
        CREATE VIEW masked_alert_history AS
        SELECT
            alert_id,
            CASE WHEN current_user = 'admin' THEN server_id ELSE '*****' END AS server_id,
            alert_type,
            alert_status
        FROM alert_history;
        
        ```
        
        - Protects **sensitive infrastructure details** from unauthorized access.
- **Implement TLS encryption for in-transit data.**
    - **Why?** Prevents attackers from intercepting database queries.
    - **How?**
        - Enforce **SSL/TLS connections** for PostgreSQL.
    - **Example (Force SSL in PostgreSQL Config):**
        
        ```sql
        sql
        CopyEdit
        ALTER SYSTEM SET ssl = 'on';
        
        ```
        
        - Ensures **secure client-server communication**.
- **Comply with GDPR and data privacy regulations.**
    - **Why?** If the system logs personal information (e.g., user alerts), it must follow GDPR.
    - **How?**
        - Implement **data anonymization** for sensitive user details.
        - Allow users to **request data deletion** if legally required.
    - **Example (Anonymizing User Data in Alerts):**
        
        ```sql
        sql
        CopyEdit
        UPDATE alert_history
        SET alert_type = 'REDACTED'
        WHERE alert_triggered_at < NOW() - INTERVAL '1 year';
        
        ```
        
        - Protects **privacy** while keeping system logs.