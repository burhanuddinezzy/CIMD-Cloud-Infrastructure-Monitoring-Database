CREATE EXTENSION postgis;

SELECT * FROM pg_extension WHERE extname = 'postgis';

SELECT proname FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') AND proname LIKE 'st_%' LIMIT 10;

SELECT typname FROM pg_type WHERE typname = 'geography';

DROP EXTENSION postgis;
CREATE EXTENSION postgis;