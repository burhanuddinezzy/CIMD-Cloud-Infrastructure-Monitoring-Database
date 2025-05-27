alter table server_metrics drop column db_queries_per_sec;

INSERT INTO public.location (location_id, location_name) 
VALUES ('550e8400-e29b-41d4-a716-446655440001', 'Default Location')
ON CONFLICT (location_id) DO NOTHING;


SELECT
    t.table_schema,
    t.table_name,
    c.column_name
FROM
    information_schema.tables t
JOIN
    information_schema.columns c ON t.table_schema = c.table_schema AND t.table_name = c.table_name
WHERE
    t.table_type = 'BASE TABLE'
    AND t.table_schema NOT IN ('pg_catalog', 'information_schema') -- Exclude system schemas (optional)
ORDER BY
    t.table_schema,
    t.table_name,
    c.ordinal_position;


ALTER TABLE team_members
ADD COLUMN department VARCHAR(100),
ADD CONSTRAINT role_check
CHECK (role IN ('Cloud Engineer', 'DevOps', 'Security', 'DBA', 'Network Engineer', 'Support'));

ALTER TABLE team_members DROP CONSTRAINT team_members_pkey;
ALTER TABLE team_members
ADD PRIMARY KEY (team_id, member_id);

-- Adding a composite primary key (so a table that can searched through with both rpimary keys). This is b/c
-- one member may potentially be in multiple teams (typically one). And one team will have multiple members.
-- And since i want to use this table to be able to search for who all are in any said team or which teams is 
-- any said memeber in, having a composite key will be helpful.
ALTER TABLE team_members
ADD CONSTRAINT team_members_member_id_pkeys
PRIMARY KEY (member_id, team_id);

-- dropping columns data_created and status, as this information isn't helpful to store/make use of.
-- adding column department. This was originally in team_members table, but it makes a lot moer sense for it to be
-- in the team management table, since team management focuses on team specific details, whereas team membes focuses on
-- member specific details. For this reason, I will rename team members to members (after dropping the members table)
-- as that table is holding all memeber information but then also mention what team they're in, so it's not "team member" info
-- it's more "member" info

ALTER TABLE team_management
DROP COLUMN date_created,
drop column status,
add column department VARCHAR (100);


-- Explained above reasoning behind this
alter table team_members rename to members;

-- Before dropping the table members, we need to disconnect relations from team_managemnt and team_members to members.
ALTER TABLE team_management
DROP CONSTRAINT team_management_team_lead_id_fkey;

ALTER TABLE team_members DROP CONSTRAINT team_members_member_id_fkey;
ALTER TABLE team_members DROP CONSTRAINT team_members_team_id_fkey;


-- This table holds redundent information (member_id, full_name), which I can simply house in the team_members table
-- Hence dropping it.
drop table members;

--making team_id foreign to team_management
ALTER TABLE team_members
ADD CONSTRAINT team_id_fkey_team_management
FOREIGN KEY (team_id) REFERENCES team_management(team_id) ON DELETE CASCADE;


ALTER TABLE team_management
ADD CONSTRAINT member_id_fkey_team_members
FOREIGN KEY (team_lead_id) REFERENCES team_members(member_id) ON DELETE CASCADE;


-- I realized the hard way, I cant make team_lead_id a foregin key that references member_id in team_members
-- because member_id in team_members is a composite primary key, since it's not a unique column data since one
-- member_id may show up for more than one team. Now, technically, to make it simple, I can remove the composite
-- primary key constraint, and remove the need of team_id (which is the other key that makes up the compostie key)
-- and solely make member_id the uniqkey primary key, and we will simple not care about the few exceptions 
-- where a member may be in more than one team. I don't think it's necessary to have an entire separate table just
-- for member_id and full name (which was the members table that i deleted).
-- HOWEVER. Statistically, I found out that 5% – 20% of employees in a typical company may be part of multiple teams
-- at the same time. And since im trying to design a normalized, flexible database schema to support larger orgs or 
-- future-proof scalability, it’s a good idea to allow the possibility of members being in more than one team.
-- Therefore, im bring back the members table :) 

CREATE table members (
	member_id UUID primary key default gen_random_uuid(),
	full_name VARCHAR (50),
	personal_email VARCHAR (100)
);

-- Now referencing member_id in members as a foreign key for team_members(member_id) and 
-- team_management (team_lead_id). Now there wont be the problem of member_id value reudndency
-- since it had the chance of showing up more than once in the team_members tablbe. In the members
-- table it will only show up once and can now be referenced as a foreign key since it is the primary key!

alter table team_members 
add constraint member_id_fkey_members 
foreign key (member_id) REFERENCES members(member_id) on delete cascade; 

alter table team_management add constraint team_lead_id_fkeyteam_members
foreign key (team_lead_id) references members(member_id) on delete cascade;

-- forgot to drop the department column from team_members table. its now housed in team_management table
-- where it makes more sense.

alter table team_members
drop column department;

alter table team_members
rename team_specific_email to team_member_specific_email;

alter table team_management
add column team_contact_email VARCHAR (100);

-- Removed `access_id` as an incident won't always be linked to a single user. 
-- Instead, we can create a separate `user_incidents_log` table to track user-specific incidents, 
-- which can be connected to the main incident response log as needed. At a later date. No issue in
-- creating it at a later date in terms of data loss/integrity. 

alter table incident_response_logs
drop column access_id

alter table downtime_logs
rename id to downtime_id;

ALTER table alert_configuration
add constraint contact_email_f_key_team_management
foreign key (contact_email) references team_management(team_contact_email)


ALTER TABLE team_management
ADD CONSTRAINT team_contact_email UNIQUE (team_contact_email);

ALTER TABLE application_logs
drop column app_name;

ALTER TABLE application_logs
drop column error_code;

ALTER TABLE application_logs
add column app_id UUID unique not null,
add constraint app_id_f_key_applications foreign key (app_id) references applications(app_id) on delete cascade;

ALTER TABLE error_logs
ADD COLUMN log_id UUID UNIQUE NOT NULL;

alter table team_management
drop column location;

ALTER TABLE error_logs
ADD CONSTRAINT log_id_f_key_application_logs
FOREIGN KEY (log_id) REFERENCES application_logs(log_id)
ON DELETE CASCADE;

alter table cost_data
ALTER COLUMN team_allocation TYPE UUID USING team_allocation::UUID;

alter table cost_data
add constraint f_key_team_allocation foreign key (team_allocation) references team_management(team_id) on delete cascade;

alter table alert_configuration -- sticking contact_email to team_management team_contact_email
add constraint f_key_contact_email_to_team_management foreign key (contact_email) references team_management(team_contact_email) on delete cascade;

alter table server_metrics
rename region to location_id;

alter tabLe server_metrics
alter column location_id type UUID USING location_id::uuid

alter table server_metrics
add constraint f_key_location_id_to_location foreign key (location_id) references location(location_id) on delete cascade;

alter table users 
add column location_id UUID unique not null;

alter table users
add constraint f_key_constraint_id_to_location foreign key  (location_id) references location(location_id) on delete cascade;

alter table members
add column location_id UUID unique not null;

alter table members
add constraint f_key_location_id_to_location foreign key (location_id) references location(location_id) on delete cascade;

alter table team_management
add column team_office_location_id UUID unique not null;

alter table team_management 
add constraint f_key_team_office_location_id_to_location foreign key (team_office_location_id) references location(location_id) on delete cascade;

alter table cost_data
drop column region;


-- I need to do the below, because i just realized that the server_metrics table will always have more than one row per server_id...

-- 1. Add timestamp columns to referencing tables if not present
ALTER TABLE user_access_logs ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE aggregated_metrics ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE alert_history ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE application_logs ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE resource_allocation ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE alert_configuration ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE cost_data ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE downtime_logs ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE error_logs ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE incident_response_logs ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;
ALTER TABLE team_server_assignment ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP;

-- 2. Drop old foreign key constraints
ALTER TABLE user_access_logs DROP CONSTRAINT IF EXISTS user_access_logs_server_id_fkey;
ALTER TABLE aggregated_metrics DROP CONSTRAINT IF EXISTS aggregated_metrics_server_id_fkey;
ALTER TABLE alert_history DROP CONSTRAINT IF EXISTS alert_history_server_id_fkey;
ALTER TABLE application_logs DROP CONSTRAINT IF EXISTS application_logs_server_id_fkey;
ALTER TABLE resource_allocation DROP CONSTRAINT IF EXISTS resource_allocation_server_id_fkey;
ALTER TABLE alert_configuration DROP CONSTRAINT IF EXISTS alert_configuration_server_id_fkey;
ALTER TABLE cost_data DROP CONSTRAINT IF EXISTS cost_data_server_id_fkey;
ALTER TABLE downtime_logs DROP CONSTRAINT IF EXISTS downtime_logs_server_id_fkey;
ALTER TABLE error_logs DROP CONSTRAINT IF EXISTS error_logs_server_id_fkey;
ALTER TABLE incident_response_logs DROP CONSTRAINT IF EXISTS incident_response_logs_server_id_fkey;
ALTER TABLE team_server_assignment DROP CONSTRAINT IF EXISTS team_server_assignment_server_id_fkey;

-- 3. Drop the old primary key
ALTER TABLE server_metrics DROP CONSTRAINT server_metrics_pkey;

-- 4. Add the new composite primary key
ALTER TABLE server_metrics ADD PRIMARY KEY (server_id, timestamp);

-- 5. Recreate foreign keys to reference the new composite PK
ALTER TABLE user_access_logs
  ADD CONSTRAINT user_access_logs_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE aggregated_metrics
  ADD CONSTRAINT aggregated_metrics_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE alert_history
  ADD CONSTRAINT alert_history_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE application_logs
  ADD CONSTRAINT application_logs_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE resource_allocation
  ADD CONSTRAINT resource_allocation_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE alert_configuration
  ADD CONSTRAINT alert_configuration_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE cost_data
  ADD CONSTRAINT cost_data_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE downtime_logs
  ADD CONSTRAINT downtime_logs_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE error_logs
  ADD CONSTRAINT error_logs_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE incident_response_logs
  ADD CONSTRAINT incident_response_logs_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

ALTER TABLE team_server_assignment
  ADD CONSTRAINT team_server_assignment_server_id_timestamp_fkey
  FOREIGN KEY (server_id, timestamp)
  REFERENCES server_metrics(server_id, timestamp);

