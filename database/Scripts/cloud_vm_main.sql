CREATE EXTENSION postgis;

SELECT * FROM pg_extension WHERE extname = 'postgis';

SELECT proname FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') AND proname LIKE 'st_%' LIMIT 10;

SELECT typname FROM pg_type WHERE typname = 'geography';

drop extension postgis;
-- public.applications definition

-- Drop table

-- DROP TABLE applications;

CREATE TABLE applications (
	app_id uuid DEFAULT gen_random_uuid() NOT NULL,
	app_name varchar(255) NOT NULL,
	app_type varchar(100) NOT NULL,
	hosting_environment varchar(50) DEFAULT 'Unknown'::character varying NULL,
	CONSTRAINT applications_hosting_environment_check CHECK (((hosting_environment)::text = ANY ((ARRAY['Containerized'::character varying, 'Virtual Machine'::character varying, 'Bare Metal'::character varying, 'Serverless'::character varying, 'Unknown'::character varying])::text[]))),
	CONSTRAINT applications_pkey PRIMARY KEY (app_id)
);


-- public."location" definition

-- Drop table

-- DROP TABLE "location";

CREATE TABLE "location" (
	location_id uuid DEFAULT gen_random_uuid() NOT NULL,
	location_geom public.geography(point, 4326) NULL,
	country varchar(100) NULL,
	region varchar(100) NULL,
	location_name varchar(255) NULL,
	CONSTRAINT location_pkey PRIMARY KEY (location_id)
);

-- public.members definition

-- Drop table

-- DROP TABLE members;

CREATE TABLE members (
	member_id uuid DEFAULT gen_random_uuid() NOT NULL,
	full_name varchar(50) NULL,
	personal_email varchar(100) NULL,
	location_id uuid NOT NULL,
	CONSTRAINT members_location_id_key UNIQUE (location_id),
	CONSTRAINT members_pkey PRIMARY KEY (member_id),
	CONSTRAINT f_key_location_id_to_location FOREIGN KEY (location_id) REFERENCES "location"(location_id) ON DELETE CASCADE
);


-- public.server_metrics definition

-- Drop table

-- DROP TABLE server_metrics;

CREATE TABLE server_metrics (
	server_id uuid NOT NULL,
	location_id uuid NOT NULL,
	"timestamp" timestamp NOT NULL,
	cpu_usage float8 NOT NULL,
	memory_usage float8 NOT NULL,
	disk_read_ops_per_sec int4 NOT NULL,
	disk_write_ops_per_sec int4 NOT NULL,
	network_in_bytes int8 NOT NULL,
	network_out_bytes int8 NOT NULL,
	uptime_in_mins int4 NOT NULL,
	latency_in_ms float8 NOT NULL,
	db_queries_per_sec int4 NOT NULL,
	disk_usage_percent float8 NOT NULL,
	error_count int4 NULL,
	disk_read_throughput int8 NOT NULL,
	disk_write_throughput int8 NOT NULL,
	CONSTRAINT server_metrics_pkey PRIMARY KEY (server_id),
	CONSTRAINT f_key_location_id_to_location FOREIGN KEY (location_id) REFERENCES "location"(location_id) ON DELETE CASCADE
);


-- public.users definition

-- Drop table

-- DROP TABLE users;

CREATE TABLE users (
	user_id uuid DEFAULT gen_random_uuid() NOT NULL,
	username varchar(50) NOT NULL,
	email varchar(255) NOT NULL,
	password_hash text NOT NULL,
	full_name varchar(100) NULL,
	date_joined timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	last_login timestamp NULL,
	location_id uuid NOT NULL,
	CONSTRAINT users_email_key UNIQUE (email),
	CONSTRAINT users_location_id_key UNIQUE (location_id),
	CONSTRAINT users_pkey PRIMARY KEY (user_id),
	CONSTRAINT users_username_key UNIQUE (username),
	CONSTRAINT f_key_constraint_id_to_location FOREIGN KEY (location_id) REFERENCES "location"(location_id) ON DELETE CASCADE
);


-- public.user_access_logs definition

-- Drop table

-- DROP TABLE user_access_logs;

CREATE TABLE user_access_logs (
	access_id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_id uuid NOT NULL,
	server_id uuid NOT NULL,
	access_type varchar(10) NULL,
	"timestamp" timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	access_ip varchar(45) NOT NULL,
	user_agent varchar(255) NOT NULL,
	CONSTRAINT user_access_logs_access_type_check CHECK (((access_type)::text = ANY ((ARRAY['READ'::character varying, 'WRITE'::character varying, 'DELETE'::character varying, 'EXECUTE'::character varying])::text[]))),
	CONSTRAINT user_access_logs_pkey PRIMARY KEY (access_id),
	CONSTRAINT user_access_logs_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE,
	CONSTRAINT user_access_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- public.aggregated_metrics definition

-- Drop table

-- DROP TABLE aggregated_metrics;

CREATE TABLE aggregated_metrics (
	server_id uuid NOT NULL,
	region varchar(20) NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	hourly_avg_cpu_usage numeric(5, 2) NOT NULL,
	hourly_avg_memory_usage numeric(5, 2) NOT NULL,
	peak_network_usage int8 NOT NULL,
	peak_disk_usage int8 NOT NULL,
	uptime_percentage numeric(5, 2) NOT NULL,
	total_requests int8 NOT NULL,
	error_rate numeric(5, 2) NOT NULL,
	average_response_time numeric(5, 2) NOT NULL,
	CONSTRAINT aggregated_metrics_pkey PRIMARY KEY (server_id, "timestamp"),
	CONSTRAINT aggregated_metrics_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE
);


-- public.alert_history definition

-- Drop table

-- DROP TABLE alert_history;

CREATE TABLE alert_history (
	alert_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NULL,
	alert_type varchar(50) NOT NULL,
	threshold_value numeric(10, 2) NOT NULL,
	alert_triggered_at timestamp DEFAULT now() NOT NULL,
	resolved_at timestamp NULL,
	alert_status varchar(10) NOT NULL,
	alert_severity varchar(10) NOT NULL,
	alert_description text NULL,
	resolved_by varchar(100) NULL,
	alert_source varchar(100) NULL,
	impact varchar(50) NULL,
	CONSTRAINT alert_history_alert_severity_check CHECK (((alert_severity)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying, 'CRITICAL'::character varying])::text[]))),
	CONSTRAINT alert_history_alert_status_check CHECK (((alert_status)::text = ANY ((ARRAY['OPEN'::character varying, 'CLOSED'::character varying])::text[]))),
	CONSTRAINT alert_history_pkey PRIMARY KEY (alert_id),
	CONSTRAINT alert_history_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE
);


-- public.application_logs definition

-- Drop table

-- DROP TABLE application_logs;

CREATE TABLE application_logs (
	log_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NOT NULL,
	log_level public."log_level_enum" NOT NULL,
	log_timestamp timestamptz DEFAULT now() NULL,
	trace_id uuid NULL,
	span_id uuid NULL,
	source_ip inet NULL,
	user_id uuid NULL,
	log_source public."log_source_enum" NOT NULL,
	app_id uuid NOT NULL,
	CONSTRAINT application_logs_app_id_key UNIQUE (app_id),
	CONSTRAINT application_logs_pkey PRIMARY KEY (log_id),
	CONSTRAINT app_id_f_key_applications FOREIGN KEY (app_id) REFERENCES applications(app_id) ON DELETE CASCADE,
	CONSTRAINT application_logs_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE,
	CONSTRAINT application_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);


-- public.resource_allocation definition

-- Drop table

-- DROP TABLE resource_allocation;

CREATE TABLE resource_allocation (
	server_id uuid NOT NULL,
	app_id uuid NOT NULL,
	workload_type varchar(50) NOT NULL,
	allocated_memory int4 NOT NULL,
	allocated_cpu numeric(5, 2) NOT NULL,
	allocated_disk_space int4 NOT NULL,
	resource_tag varchar(100) NULL,
	"timestamp" timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	utilization_percentage numeric(5, 2) NULL,
	autoscaling_enabled bool DEFAULT false NULL,
	max_allocated_memory int4 NULL,
	max_allocated_cpu numeric(5, 2) NULL,
	max_allocated_disk_space int4 NULL,
	actual_memory_usage int4 NULL,
	actual_cpu_usage numeric(5, 2) NULL,
	actual_disk_usage int4 NULL,
	cost_per_hour numeric(10, 4) NOT NULL,
	allocation_status varchar(20) NULL,
	CONSTRAINT resource_allocation_allocation_status_check CHECK (((allocation_status)::text = ANY ((ARRAY['active'::character varying, 'pending'::character varying, 'deallocated'::character varying])::text[]))),
	CONSTRAINT resource_allocation_pkey PRIMARY KEY (server_id, app_id),
	CONSTRAINT resource_allocation_app_id_fkey FOREIGN KEY (app_id) REFERENCES applications(app_id) ON DELETE CASCADE,
	CONSTRAINT resource_allocation_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE
);


-- public.alert_configuration definition

-- Drop table

-- DROP TABLE alert_configuration;

CREATE TABLE alert_configuration (
	alert_config_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NOT NULL,
	metric_name varchar(50) NOT NULL,
	threshold_value float8 NOT NULL,
	alert_frequency interval NOT NULL,
	contact_email varchar(255) NOT NULL,
	alert_enabled bool DEFAULT true NULL,
	alert_type text NOT NULL,
	severity_level text NOT NULL,
	CONSTRAINT alert_configuration_alert_type_check CHECK ((alert_type = ANY (ARRAY['EMAIL'::text, 'SMS'::text, 'WEBHOOK'::text, 'SLACK'::text]))),
	CONSTRAINT alert_configuration_pkey PRIMARY KEY (alert_config_id),
	CONSTRAINT alert_configuration_severity_level_check CHECK ((severity_level = ANY (ARRAY['LOW'::text, 'MEDIUM'::text, 'HIGH'::text, 'CRITICAL'::text])))
);


-- public.cost_data definition

-- Drop table

-- DROP TABLE cost_data;

CREATE TABLE cost_data (
	server_id uuid NOT NULL,
	"timestamp" timestamp NOT NULL,
	cost_per_hour numeric(10, 2) NOT NULL,
	total_monthly_cost numeric(10, 2) NOT NULL,
	team_allocation uuid NULL,
	cost_per_day numeric(10, 2) NULL,
	cost_type varchar(50) NULL,
	cost_adjustment numeric(10, 2) NULL,
	cost_adjustment_reason text NULL,
	cost_basis varchar(50) NULL,
	CONSTRAINT cost_data_pkey PRIMARY KEY (server_id, "timestamp")
);


-- public.downtime_logs definition

-- Drop table

-- DROP TABLE downtime_logs;

CREATE TABLE downtime_logs (
	downtime_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NOT NULL,
	start_time timestamp NOT NULL,
	end_time timestamp NULL,
	downtime_duration_minutes int4 GENERATED ALWAYS AS ((EXTRACT(epoch FROM end_time - start_time) / 60::numeric)) STORED NULL,
	downtime_cause varchar(255) NOT NULL,
	sla_tracking bool NOT NULL,
	incident_id uuid NULL,
	is_planned bool NOT NULL,
	recovery_action varchar(255) NOT NULL,
	CONSTRAINT downtime_logs_pkey PRIMARY KEY (downtime_id)
);


-- public.error_logs definition

-- Drop table

-- DROP TABLE error_logs;

CREATE TABLE error_logs (
	error_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	error_severity text NOT NULL,
	error_message text NOT NULL,
	resolved bool DEFAULT false NOT NULL,
	resolved_at timestamp NULL,
	incident_id uuid NULL,
	error_source varchar(100) NOT NULL,
	error_code varchar(50) NULL,
	recovery_action varchar(255) NULL,
	log_id uuid NOT NULL,
	CONSTRAINT error_logs_error_severity_check CHECK ((error_severity = ANY (ARRAY['INFO'::text, 'WARNING'::text, 'CRITICAL'::text]))),
	CONSTRAINT error_logs_log_id_key UNIQUE (log_id),
	CONSTRAINT error_logs_pkey PRIMARY KEY (error_id)
);


-- public.incident_response_logs definition

-- Drop table

-- DROP TABLE incident_response_logs;

CREATE TABLE incident_response_logs (
	incident_id uuid DEFAULT gen_random_uuid() NOT NULL,
	server_id uuid NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	response_team_id uuid NOT NULL,
	incident_summary text NOT NULL,
	resolution_time_minutes int4 NULL,
	status varchar(50) DEFAULT 'Open'::character varying NOT NULL,
	priority_level varchar(20) DEFAULT 'Medium'::character varying NOT NULL,
	incident_type varchar(100) NOT NULL,
	root_cause text NULL,
	escalation_flag bool DEFAULT false NOT NULL,
	CONSTRAINT incident_response_logs_pkey PRIMARY KEY (incident_id),
	CONSTRAINT incident_response_logs_priority_level_check CHECK (((priority_level)::text = ANY ((ARRAY['Low'::character varying, 'Medium'::character varying, 'High'::character varying, 'Critical'::character varying])::text[]))),
	CONSTRAINT incident_response_logs_resolution_time_minutes_check CHECK ((resolution_time_minutes >= 0)),
	CONSTRAINT incident_response_logs_status_check CHECK (((status)::text = ANY ((ARRAY['Open'::character varying, 'In Progress'::character varying, 'Resolved'::character varying, 'Escalated'::character varying])::text[])))
);


-- public.team_management definition

-- Drop table

-- DROP TABLE team_management;

CREATE TABLE team_management (
	team_id uuid DEFAULT gen_random_uuid() NOT NULL,
	team_name varchar(100) NOT NULL,
	team_description text NULL,
	team_lead_id uuid NULL,
	department varchar(100) NULL,
	team_contact_email varchar(100) NULL,
	team_office_location_id uuid NOT NULL,
	CONSTRAINT team_contact_email UNIQUE (team_contact_email),
	CONSTRAINT team_management_pkey PRIMARY KEY (team_id),
	CONSTRAINT team_management_team_name_key UNIQUE (team_name),
	CONSTRAINT team_management_team_office_location_id_key UNIQUE (team_office_location_id)
);


-- public.team_members definition

-- Drop table

-- DROP TABLE team_members;

CREATE TABLE team_members (
	member_id uuid DEFAULT gen_random_uuid() NOT NULL,
	team_id uuid NULL,
	"role" varchar(50) NOT NULL,
	email varchar(255) NOT NULL,
	date_joined timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT role_check CHECK (((role)::text = ANY ((ARRAY['Cloud Engineer'::character varying, 'DevOps'::character varying, 'Security'::character varying, 'DBA'::character varying, 'Network Engineer'::character varying, 'Support'::character varying])::text[]))),
	CONSTRAINT team_members_email_key UNIQUE (email),
	CONSTRAINT team_members_pkey PRIMARY KEY (member_id)
);


-- public.team_server_assignment definition

-- Drop table

-- DROP TABLE team_server_assignment;

CREATE TABLE team_server_assignment (
	team_id uuid NOT NULL,
	server_id uuid NOT NULL,
	CONSTRAINT team_server_assignment_pkey PRIMARY KEY (team_id, server_id)
);


-- public.alert_configuration foreign keys

ALTER TABLE public.alert_configuration ADD CONSTRAINT alert_configuration_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;
ALTER TABLE public.alert_configuration ADD CONSTRAINT f_key_contact_email_to_team_management FOREIGN KEY (contact_email) REFERENCES team_management(team_contact_email) ON DELETE CASCADE;


-- public.cost_data foreign keys

ALTER TABLE public.cost_data ADD CONSTRAINT cost_data_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;
ALTER TABLE public.cost_data ADD CONSTRAINT f_key_team_allocation FOREIGN KEY (team_allocation) REFERENCES team_management(team_id) ON DELETE CASCADE;


-- public.downtime_logs foreign keys

ALTER TABLE public.downtime_logs ADD CONSTRAINT downtime_logs_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES incident_response_logs(incident_id) ON DELETE SET NULL;
ALTER TABLE public.downtime_logs ADD CONSTRAINT downtime_logs_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;


-- public.error_logs foreign keys

ALTER TABLE public.error_logs ADD CONSTRAINT error_logs_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES incident_response_logs(incident_id) ON DELETE SET NULL;
ALTER TABLE public.error_logs ADD CONSTRAINT error_logs_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;
ALTER TABLE public.error_logs ADD CONSTRAINT log_id_f_key_application_logs FOREIGN KEY (log_id) REFERENCES application_logs(log_id) ON DELETE CASCADE;


-- public.incident_response_logs foreign keys

ALTER TABLE public.incident_response_logs ADD CONSTRAINT incident_response_logs_response_team_id_fkey FOREIGN KEY (response_team_id) REFERENCES team_management(team_id) ON DELETE SET NULL;
ALTER TABLE public.incident_response_logs ADD CONSTRAINT incident_response_logs_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;


-- public.team_management foreign keys

ALTER TABLE public.team_management ADD CONSTRAINT f_key_team_office_location_id_to_location FOREIGN KEY (team_office_location_id) REFERENCES "location"(location_id) ON DELETE CASCADE;
ALTER TABLE public.team_management ADD CONSTRAINT member_id_fkey_team_members FOREIGN KEY (team_lead_id) REFERENCES team_members(member_id) ON DELETE CASCADE;
ALTER TABLE public.team_management ADD CONSTRAINT team_lead_id_fkeyteam_members FOREIGN KEY (team_lead_id) REFERENCES members(member_id) ON DELETE CASCADE;


-- public.team_members foreign keys

ALTER TABLE public.team_members ADD CONSTRAINT f_key_team_id_to_team_management FOREIGN KEY (team_id) REFERENCES team_management(team_id) ON DELETE CASCADE;
ALTER TABLE public.team_members ADD CONSTRAINT member_id_fkey_members FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE;
ALTER TABLE public.team_members ADD CONSTRAINT team_id_fkey_team_management FOREIGN KEY (team_id) REFERENCES team_management(team_id) ON DELETE CASCADE;


-- public.team_server_assignment foreign keys

ALTER TABLE public.team_server_assignment ADD CONSTRAINT team_server_assignment_server_id_fkey FOREIGN KEY (server_id) REFERENCES server_metrics(server_id) ON DELETE CASCADE;
ALTER TABLE public.team_server_assignment ADD CONSTRAINT team_server_assignment_team_id_fkey FOREIGN KEY (team_id) REFERENCES team_management(team_id) ON DELETE CASCADE;