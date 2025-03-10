# User Access Logs

This table stores **detailed logs of user interactions with servers and applications**, capturing access events for **security auditing and monitoring purposes**. It helps track **who accessed what, when, and from where**, which is crucial for security and compliance auditing in cloud environments.

### **Data Points (Columns) – Purpose, Thought Process, and Data Type**

- **`access_id` (UUID, Primary Key)**
    - **Purpose**: Uniquely identifies each access log entry.
    - **Why I Thought of Adding It**: Required to track individual access events for auditing and filtering.
    - **How I Thought of Adding It**: Ensures each record can be referenced independently in a high-traffic environment.
    - **Data Type Used & Why**: `UUID` ensures unique identification across distributed systems without collisions.
- **`user_id` (UUID, Foreign Key)**
    - **Purpose**: Identifies the user who accessed the server or application.
    - **Why I Thought of Adding It**: Needed to track specific user activity and identify potential security breaches or unauthorized actions.
    - **How I Thought of Adding It**: Critical for user activity monitoring, allowing admins to know who performed what actions.
    - **Data Type Used & Why**: `UUID` ensures that user identifiers remain unique and consistent across systems.
- **`server_id` (UUID, Foreign Key)**
    - **Purpose**: Links the access log to the specific server being accessed.
    - **Why I Thought of Adding It**: Needed to correlate user access with specific servers in a distributed infrastructure.
    - **How I Thought of Adding It**: Helps identify which servers are being targeted or accessed more frequently by users.
    - **Data Type Used & Why**: `UUID` keeps consistency with other tables like `server_metrics` and ensures referential integrity.
- **`access_type` (ENUM('READ', 'WRITE', 'DELETE', 'EXECUTE'))**
    - **Purpose**: Denotes the type of access the user performed.
    - **Why I Thought of Adding It**: Essential for tracking different types of actions on servers, such as reading data or modifying it.
    - **How I Thought of Adding It**: Crucial for security auditing; different access types require different levels of scrutiny.
    - **Data Type Used & Why**: `ENUM` ensures only valid types are stored and allows for efficient querying on specific access types.
- **`timestamp` (TIMESTAMP WITH TIME ZONE)**
    - **Purpose**: Captures the exact time when the access event occurred.
    - **Why I Thought of Adding It**: Needed for time-based analysis to detect abnormal access patterns, such as login attempts at odd hours.
    - **How I Thought of Adding It**: Provides a temporal context for when an event occurred, enabling the identification of suspicious access.
    - **Data Type Used & Why**: `TIMESTAMP WITH TIME ZONE` is used to account for time zones in a global infrastructure and ensure consistency.
- **`access_ip` (VARCHAR(45))**
    - **Purpose**: Records the IP address from which the user accessed the server or application.
    - **Why I Thought of Adding It**: Needed to track where the access came from, which can help detect anomalies such as access from suspicious locations.
    - **How I Thought of Adding It**: Essential for identifying potential security threats and performing geolocation analysis on user behavior.
    - **Data Type Used & Why**: `VARCHAR(45)` supports both IPv4 and IPv6 addresses, ensuring flexibility in the types of IP addresses that can be recorded.
- **`user_agent` (VARCHAR(255))**
    - **Purpose**: Records the client or browser used by the user to access the server or application.
    - **Why I Thought of Adding It**: Important for identifying suspicious access patterns, such as logins from unfamiliar devices, browsers, or locations.
    - **How I Thought of Adding It**: Helps with security audits, forensics, and identifying potential misuse or unauthorized access from unusual clients.
    - **Data Type Used & Why**: `VARCHAR(255)` is used because user-agent strings are text-based and vary in length, making this type suitable for storing detailed client information.

[**How It Interacts with Other Tables**:](User%20Access%20Logs%2019bead362d9380dfbc13ec57ebd95e94/How%20It%20Interacts%20with%20Other%20Tables%2019dead362d9380c8b954ead117f47b19.md)

- **Example of Stored Data**
    
    
    | access_id | user_id | server_id | access_type | timestamp | access_ip |
    | --- | --- | --- | --- | --- | --- |
    | `a1b2c3d4` | `usr123` | `srv456` | `READ` | `2024-01-31 12:00:00 UTC` | `192.168.1.10` |
    | `d5e6f7g8` | `usr789` | `srv123` | `WRITE` | `2024-01-31 12:05:10 UTC` | `203.0.113.45` |


## Dive Into Detail

- [**Alerting & Automation**](Alerting%20&%20Automation.md)
- [**Alternative Approaches**](Alternative%20Approaches.md)
- [**Data Retention & Cleanup**](Data%20Retention%20&%20Cleanup.md)
- [**Handling Large-Scale Data**](Handling%20Large-Scale%20Data.md)
- [**How It Interacts with Other Tables**](How%20It%20Interacts%20with%20Other%20Tables.md)
- [**How You Tested & Validated Data Integrity**](How%20You%20Tested%20&%20Validated%20Data%20Integrity.md)
- [**Performance Considerations & Scalability**](Performance%20Considerations%20&%20Scalability.md)
- [**Query Optimization Techniques**](Query%20Optimization%20Techniques.md)
- [**READ ME User Access Logs**](READ%20ME%20User%20Access%20Logs.md)
- [**Real-World Use Cases**](Real-World%20Use%20Cases.md)
- [**Security & Compliance**](Security%20&%20Compliance.md)
- [**Thought Process Behind Decisions**](Thought%20Process%20Behind%20Decisions.md)
- [**What Queries Would Be Used**](What%20Queries%20Would%20Be%20Used.md)

