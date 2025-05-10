# Cloud Infrastructure Monitoring Database (CIMD)


## Table of Contents
1. [Project Title](#cloud-infrastructure-monitoring-database-cimd)
2. [Overview](#overview)
3. [Key Features](#key-features)
4. [Database Schema](#database-schema)
5. [Technology Stack](#technology-stack)
6. [Setup and Installation](#setup-and-installation)
7. [Data Ingestion](#data-ingestion)
8. [Potential Use Cases](#potential-use-cases)
9. [Future Enhancements](#future-enhancements)
10. [Contributing](#contributing) (If applicable)
11. [License](#license) (If applicable)
12. [Contact](#contact)
4. Key Features:

## Overview

The **Cloud Infrastructure Monitoring Database (CIMD)** is a comprehensive data repository designed to facilitate robust cloud observability. Its architecture integrates a variety of data sources, including:

* **Aggregated Performance Metrics:** Summarized server performance data (CPU, memory, network, disk) over time, providing insights into resource utilization trends.
* **Real-time Server Metrics:** Granular, point-in-time data on server health and performance, enabling immediate issue detection.
* **Application Logs:** Detailed records of application behavior, errors, and events, crucial for debugging and understanding application flow.
* **Error Logs:** Specific records of system and application errors, facilitating root cause analysis.
* **User Access Logs:** Information on who is accessing which servers and when, enhancing security monitoring and auditing.
* **Alert Configurations:** Defined rules and thresholds for triggering notifications on critical events and performance deviations.
* **Alert History:** A log of all triggered alerts, their status, resolution times, and contributing factors.
* **Downtime Logs:** Records of system outages, their duration, causes, and planned/unplanned status, essential for SLA tracking.
* **Incident Response Logs:** A detailed history of incident management activities, including response teams, timelines, resolutions, and root causes.
* **Cost Data:** Information related to cloud resource consumption and associated costs, enabling cost optimization and tracking.
* **Resource Allocation:** Details on how resources (CPU, memory, disk) are allocated to different servers and applications.
* **Application Inventory:** A catalog of deployed applications, their types, and hosting environments.
* **Server Inventory:** Basic information about the monitored servers (implicitly through `server_id` across tables).
* **Team Management:** Information about teams responsible for different aspects of the infrastructure.
* **Team Members:** Details about individual team members and their roles.
* **Team Server Assignments:** Records of which teams are responsible for specific servers.
* **Location Data:** Geographic information associated with servers and potentially users.

By centralizing and structuring this diverse data, the CIMD aims to provide a holistic view of cloud infrastructure health, facilitate proactive alerting, accelerate incident resolution, optimize resource utilization, and enable data-driven decision-making for improved reliability and performance.

**Unique Geospatial Advantage:**

A key differentiator of this CIMD lies in its provision of extremely granular, coordinate-level geospatial data, in contrast to conventional Cloud Infrastructure Monitoring Databases that typically offer only high-level regional information. This unique capability positions the CIMD as particularly advantageous for industries and companies requiring precise location intelligence for their infrastructure. Sectors such as logistics and supply chain management (for tracking server locations critical to delivery networks), telecommunications (for optimizing network infrastructure based on exact geographic coordinates), and geographically distributed IoT deployments (where pinpointing the location of edge devices and their associated server performance is paramount) stand to benefit significantly from this enhanced spatial accuracy. This in-depth geospatial tracking enables use cases ranging from latency optimization based on physical proximity to enhanced compliance and regulatory adherence tied to specific geographic zones.

## Technology Stack (To Date)
- **Database**: PostgreSQL RDBMS (hosted on Oracle Cloud's free-tier VM Instance)
- **Database IDE**: DBeaver
- **Backend**: Python (For scripting)
- **Frontend**: NA
- **Cloud Integration**: Yes - Oracle Cloud (Free Tier; As this is a project)

**Manual Cloud VM and Database Setup**

All infrastructure and database setup for this project was performed manually on a cloud Virtual Machine instance. This deliberate approach involved provisioning the VM, configuring the operating system, installing and configuring PostgreSQL, and setting up the database schema entirely through command-line interfaces and SQL scripting. This hands-on process was chosen to explicitly demonstrate my proficiency in cloud infrastructure fundamentals, PostgreSQL administration, SQL scripting, and system integration, without reliance on automated deployment tools or managed database services.

Detailed steps and relevant command outputs are documented in [detailed_cloud_setup_documentation](database/cloud_setup).

4. Key Features:
A bulleted list highlighting the most important aspects and capabilities of your database. This could include:
Integration of various telemetry data sources.
Real-time and historical performance monitoring.
Comprehensive logging and error tracking.
Advanced alerting and incident management capabilities.
Cost analysis and resource allocation insights.
Unique coordinate-level geospatial data tracking.
Scalable design.
Well-defined schema for efficient querying.


## Database Schema
For a detailed overview of the database schema, including table descriptions and column definitions, please refer to [Database Architecture](database/db_architecture.md)

## Entity Relationship Diagram
![Entity Relationship Diagram (Last updated 10-05-2025)](database/Diagrams/erd-5.10.2025.png)

6. Technology Stack:

List the technologies you used to build this database project. This includes:

Database system (e.g., PostgreSQL)
Any ORM or database management tools (e.g., DBeaver)
Programming languages used for any related scripts or applications (if applicable)
Cloud platforms if you deployed it there (though it sounds like it's currently local)
Markdown

## Technology Stack

* **Database:** PostgreSQL
* **Database Management Tool:** DBeaver
* **Other Tools:** (Mention any other tools you used)
7. Setup and Installation:

Provide clear instructions on how someone else (or your future self) can set up and run your database. This might involve:

Prerequisites (e.g., PostgreSQL installation).
Steps to create the database and tables (you might include the SQL scripts if you have them).
Configuration details if any.
Markdown

## Setup and Installation

1.  Ensure you have PostgreSQL installed on your system.
2.  Create a new database named `cimd` (or your preferred name).
3.  You can use the SQL scripts in the `sql/` directory (if you have them) to create the tables:
    ```bash
    psql -U your_user -d cimd -f sql/schema.sql
    ```
    (Replace `your_user` and adjust the path if necessary).
4.  (Optional) Instructions on how to populate the database with sample data.
8. Data Ingestion (If applicable):

If you have scripts or methods for populating the database with data, briefly describe them here.

9. Potential Use Cases:

Expand on the "Unique Geospatial Advantage" section by providing more specific and compelling use cases that your CIMD enables. Think about how different industries could leverage this detailed data. Examples:
Telecommunications: Real-time network performance monitoring with precise geographic location of network nodes for faster troubleshooting and optimization.
Logistics: Tracking the performance and health of servers located in different warehouses or along transportation routes, correlated with delivery times and potential bottlenecks.
Smart Cities: Monitoring the infrastructure of smart city devices (e.g., traffic sensors, environmental monitors) with precise location data for efficient management and maintenance.
Disaster Recovery: Identifying the geographic location of impacted infrastructure during outages for targeted recovery efforts.

10. Future Enhancements:

Briefly mention any features or improvements you plan to add to the database in the future. This shows that the project is ongoing and you have a vision for its development. Examples:
Integration with specific monitoring tools.
Advanced analytics and visualization capabilities.
More sophisticated alerting rules.
Scalability improvements.

11. Contributing (If applicable):

If you're open to contributions from others, explain how they can contribute (e.g., reporting issues, submitting pull requests).

13. Contact:

Provide your contact information (e.g., email, GitHub profile) if you want people to be able to reach out with questions or feedback.