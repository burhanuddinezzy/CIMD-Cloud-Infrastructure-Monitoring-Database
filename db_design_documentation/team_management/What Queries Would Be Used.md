# What Queries Would Be Used?

1. **Find all team members of a specific team:**

```sql
sql
CopyEdit
SELECT * FROM team_management
WHERE team_name = 'DevOps Team';

```

- **Purpose**: Retrieve details of all members who belong to the "DevOps Team".
- **Explanation**: This query helps fetch all records associated with team members under the DevOps team, providing insights into the team's composition.

---

1. **Find the team responsible for a given server:**

```sql
sql
CopyEdit
SELECT team_name FROM team_management
WHERE 'srv-101' = ANY (assigned_server_ids);

```

- **Purpose**: Identify which team is responsible for managing the server with ID 'srv-101'.
- **Explanation**: This query uses the `ANY` operator to check if the given server ID is part of the `assigned_server_ids` array or list, returning the corresponding team name.

---

1. **Retrieve all servers managed by a specific team:**

```sql
sql
CopyEdit
SELECT assigned_server_ids FROM team_management
WHERE team_name = 'Security Team';

```

- **Purpose**: Retrieve a list of all server IDs managed by the "Security Team".
- **Explanation**: This helps you quickly identify which servers are under the purview of the security team, which is critical for monitoring, troubleshooting, or cost allocation.

---

### **Additional Queries:**

1. **Find all teams that have access to a specific server:**

```sql
sql
CopyEdit
SELECT team_name FROM team_management
WHERE 'srv-101' = ANY (assigned_server_ids);

```

- **Purpose**: Retrieve all teams that are assigned to manage or have access to the server 'srv-101'.
- **Explanation**: This query helps find all teams associated with a particular server, which is useful for collaboration or incident resolution when multiple teams are involved.

---

1. **List all members of a team and their roles:**

```sql
sql
CopyEdit
SELECT member_id, role FROM team_management
WHERE team_name = 'DevOps Team';

```

- **Purpose**: Fetch the member IDs and roles of all individuals in the "DevOps Team".
- **Explanation**: This query is useful when you need to review the roles and responsibilities within a specific team for permissions or accountability purposes.

---

1. **Find the contact emails of all team members in a specific team:**

```sql
sql
CopyEdit
SELECT email FROM team_management
WHERE team_name = 'Engineering Team';

```

- **Purpose**: Retrieve the email addresses of all members in the "Engineering Team".
- **Explanation**: This query could be useful for alerting or communication purposes, especially when sending out notifications or escalations for issues related to servers managed by this team.

---

1. **Get teams with no assigned servers (unassigned teams):**

```sql
sql
CopyEdit
SELECT team_name FROM team_management
WHERE assigned_server_ids IS NULL OR assigned_server_ids = '[]';

```

- **Purpose**: Identify teams that have no servers assigned to them.
- **Explanation**: This query helps detect teams that might have been created but aren't actively managing any resources, which could signal an issue with resource allocation or an inactive team.

---

1. **Get all servers assigned to a team, along with server health metrics:**

```sql
sql
CopyEdit
SELECT tm.team_name, sm.server_id, sm.cpu_usage, sm.memory_usage
FROM team_management tm
JOIN server_metrics sm ON sm.server_id = ANY(tm.assigned_server_ids)
WHERE tm.team_name = 'DevOps Team';

```

- **Purpose**: Retrieve all servers assigned to the "DevOps Team" along with their latest health metrics (CPU usage, memory usage).
- **Explanation**: This query provides a snapshot of the infrastructure under the DevOps team's management and is valuable for ongoing monitoring, performance checks, and alerting.

---

These queries show how the **Team Management** table interacts with various server and resource data, ensuring proper accountability, access control, and operational monitoring within the organization. They also enable efficient cross-referencing of server ownership and personnel, making it easier to identify potential issues and quickly resolve them.