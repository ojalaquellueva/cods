-- -----------------------------------------------------------------
-- Creates core tables other than gadm
-- -----------------------------------------------------------------

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (
db_version text DEFAULT NULL,
code_version text DEFAULT NULL,
build_date date
);

DROP TABLE IF EXISTS institution;
CREATE TABLE institution (
id bigserial primary key,
institution_code text,
institution_name text,
institution_type text,
country text,
state_province text,
latitude double precision,
longitude double precision
);
-- Add the wgs84 point geometry column with constraints
-- See: https://postgis.net/docs/AddGeometryColumn.html
-- Also: https://gis.stackexchange.com/questions/8699/creating-spatial-tables-with-postgis
SELECT AddGeometryColumn ('public','institution','geom',4326,'POINT',2, false);

-- Proximity user data
-- Will be used at template for job-specific proximity user data tables
DROP TABLE IF EXISTS user_data_prox CASCADE;
CREATE TABLE user_data_prox (
id serial primary key,
job text DEFAULT NULL,
user_id text DEFAULT NULL,
country_state_latlong text DEFAULT NULL,
country text DEFAULT NULL,
state_province text DEFAULT NULL,
latitude_verbatim text DEFAULT NULL,
longitude_verbatim text DEFAULT NULL,
latitude double precision DEFAULT NULL,
longitude double precision DEFAULT NULL,
dist_min_km double precision DEFAULT NULL,
dist_threshold_km INTEGER DEFAULT NULL,
institution_id INTEGER DEFAULT NULL,
institution_code text DEFAULT NULL,
institution_name text DEFAULT NULL,
is_cultivated_observation smallint DEFAULT 0,
is_cultivated_observation_reason text DEFAULT NULL,
date_created timestamp not null default now()
);
-- Add the wgs84 point geometry column with constraints
SELECT AddGeometryColumn ('public','user_data_prox','geom',4326,'POINT',2, false);

-- Keyword user data table
-- Also used as template for job-specific keyword user data tables
DROP TABLE IF EXISTS user_data_keyword CASCADE;
CREATE TABLE user_data_keyword (
id serial primary key,
job text DEFAULT NULL,
user_id text DEFAULT NULL,
tbl_name text DEFAULT NULL,
tbl_id text DEFAULT NULL,
description text DEFAULT NULL,
description_unaccent text DEFAULT NULL,
is_cultivated_observation smallint DEFAULT 0,
is_cultivated_observation_reason text,
date_created timestamp not null default now(),
done smallint default 0
);

--
-- Add indexes
--

-- user_data_prox
-- CREATE INDEX user_data_prox_job_idx ON user_data_prox USING btree (job);
-- CREATE INDEX user_data_prox_country_idx ON user_data_prox USING btree (country);
-- CREATE INDEX user_data_prox_state_province_idx ON user_data_prox USING btree (state_province);
CREATE INDEX user_data_prox_institution_id_idx ON user_data_prox USING btree (institution_id);
CREATE INDEX user_data_prox_geom_idx ON user_data_prox USING GIST (geom);

-- user_data_keyword
-- CREATE INDEX user_data_keyword_job_idx ON user_data_keyword USING btree (job);
CREATE INDEX user_data_keyword_done_idx ON user_data_keyword USING btree (done);
