# Security & Compliance

### **1. Role-Based Access Control (RBAC) for Data Protection**

- Implement **fine-grained access controls** to restrict data visibility based on user roles.
- Example roles:
    - **Admin:** Full access to all metrics and logs.
    - **DevOps:** Read/write access to real-time server metrics, but no cost data.
    - **Auditor:** Read-only access to historical logs and alerts.
    - **Application Users:** Limited access to their own server metrics.
- **PostgreSQL Implementation:**
    
    ```sql
    sql
    CopyEdit
    CREATE ROLE devops_user;
    GRANT SELECT, INSERT, UPDATE ON server_metrics TO devops_user;
    
    CREATE ROLE auditor;
    GRANT SELECT ON error_logs, downtime_logs TO auditor;
    
    CREATE ROLE app_user;
    GRANT SELECT ON server_metrics TO app_user;
    REVOKE SELECT ON cost_data FROM app_user;
    
    ```
    
- Use **Row-Level Security (RLS)** to enforce per-user restrictions:
    
    ```sql
    sql
    CopyEdit
    ALTER TABLE server_metrics ENABLE ROW LEVEL SECURITY;
    
    CREATE POLICY server_metrics_policy
    ON server_metrics
    FOR SELECT
    USING (current_user = owner);
    
    ```
    

### **2. Anonymization of Sensitive Metadata**

- **Mask or anonymize PII (Personally Identifiable Information)** before storage.
- Example: Hashing IP addresses before storing them.
    
    ```sql
    sql
    CopyEdit
    UPDATE user_access_logs
    SET ip_address = encode(digest(ip_address, 'sha256'), 'hex');
    
    ```
    
- **Remove sensitive data from logs before archiving:**
    
    ```sql
    sql
    CopyEdit
    DELETE FROM error_logs WHERE message LIKE '%password%';
    
    ```
    
- **Store only hashed passwords** using bcrypt:
    
    ```python
    python
    CopyEdit
    from bcrypt import hashpw, gensalt
    password_hash = hashpw(b'UserPassword123', gensalt())
    
    ```
    

### **3. Data Encryption at Rest & In Transit**

- **Use Transparent Data Encryption (TDE)** for PostgreSQL to protect data at rest.
    
    ```sql
    sql
    CopyEdit
    CREATE EXTENSION pgcrypto;
    UPDATE server_metrics
    SET network_in_bytes = pgp_sym_encrypt(network_in_bytes::text, 'encryption_key');
    
    ```
    
- **Enable TLS for database connections** to encrypt data in transit.
    
    ```
    sh
    CopyEdit
    psql "sslmode=require host=mydb.com dbname=mydb user=myuser"
    
    ```
    

### **4. Audit Logging for Security & Compliance**

- Track **who accessed which metrics and when** to detect unauthorized access.
- **Enable PostgreSQL audit logging:**
    
    ```sql
    sql
    CopyEdit
    ALTER SYSTEM SET log_statement = 'all';
    
    ```
    
- **Create an access log table:**
    
    ```sql
    sql
    CopyEdit
    CREATE TABLE audit_logs (
        log_id SERIAL PRIMARY KEY,
        user_name TEXT,
        action TEXT,
        table_name TEXT,
        timestamp TIMESTAMP DEFAULT now()
    );
    
    ```
    
- **Automatically log access attempts:**
    
    ```sql
    sql
    CopyEdit
    CREATE OR REPLACE FUNCTION log_access() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO audit_logs (user_name, action, table_name)
        VALUES (current_user, TG_OP, TG_TABLE_NAME);
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
    CREATE TRIGGER track_selects
    AFTER SELECT ON server_metrics
    FOR EACH ROW EXECUTE FUNCTION log_access();
    
    ```
    

### **5. Compliance with GDPR, SOC2, and HIPAA**

- **Right to be Forgotten:** Allow users to request deletion of their data.
    
    ```sql
    sql
    CopyEdit
    DELETE FROM user_access_logs WHERE user_id = 'some_user_id';
    
    ```
    
- **Data Minimization:** Only collect essential metrics, avoid storing user-specific details.
- **Access Logs Retention Policy:**
    - **General access logs:** Retain for **90 days**.
    - **Incident response logs:** Retain for **1 year** for security investigations.

### **6. Security Incident Response & Alerts**

- **Detect anomalies in resource usage** (e.g., a server suddenly sending excessive network traffic).
- **Automate security alerts:**
    
    ```sql
    sql
    CopyEdit
    CREATE FUNCTION alert_high_cpu_usage() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.cpu_usage > 95 THEN
            INSERT INTO alerts_history (server_id, alert_type, created_at)
            VALUES (NEW.server_id, 'High CPU Usage', now());
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
    CREATE TRIGGER cpu_usage_trigger
    AFTER INSERT OR UPDATE ON server_metrics
    FOR EACH ROW EXECUTE FUNCTION alert_high_cpu_usage();
    
    ```
    
- **Integrate with SIEM (Security Information and Event Management) tools** to monitor security threats.

### **7. Regular Security Audits & Penetration Testing**

- **Run vulnerability scans on the database** to identify misconfigurations.
- **Use database activity monitoring (DAM) tools** for real-time intrusion detection.
- **Periodically rotate encryption keys and credentials** to prevent leaks.

### **8. Backup & Disaster Recovery Planning**

- **Encrypt backups before storing them:**
    
    ```
    sh
    CopyEdit
    pg_dump -U myuser -h mydb.com -F c mydb | gpg --symmetric --cipher-algo AES256 -o backup.sql.gpg
    
    ```
    
- **Keep redundant backups across multiple cloud regions** to ensure disaster recovery.
- **Test data restoration processes regularly** to ensure backups are usable.

### **Final Takeaways**

- **Enforce Role-Based Access Control (RBAC) and Row-Level Security (RLS).**
- **Encrypt data both at rest and in transit for maximum protection.**
- **Audit logs and anomaly detection mechanisms ensure security compliance.**
- **Adhere to GDPR, SOC2, HIPAA by implementing data retention and deletion policies.**
- **Regularly conduct security audits and penetration tests to identify vulnerabilities.**

Need help **hardening your PostgreSQL database security** or **setting up compliance automation**? 🚀