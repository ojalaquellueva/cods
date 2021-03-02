-- ----------------------------------------------------------
-- Calculate distance to the nearest biodiversity institution
--
-- Requires parameters:
--	$tbl_user_data_raw --> :tbl_user_data_raw (batch-specific user data table)
--	${tbl_user_data_raw}_temp --> :tbl_user_data_raw (temp batch-specific table)
--	$dist_threshold --> :dist_threshold 
-- ----------------------------------------------------------

-- Find the closest biodiversity institution within the distance 
-- threshold, if any
UPDATE :tbl_user_data_raw a
SET 
institution_id=b.institution_id, 
dist_min_km=b.dist_km,
is_cultivated_observation=1,
is_cultivated_observation_reason='Proximity to herbarium/botanical garden'
FROM (
SELECT DISTINCT ON (userdata_id)
	userdata_id, institution_id, dist_m/1000 AS dist_km
FROM (
SELECT u.id AS userdata_id, i.id AS institution_id, ST_Distance(i.geom::geography, u.geom::geography) AS dist_m
FROM
  institution i,
  :tbl_user_data_raw u
WHERE ST_DWithin(u.geom::geography, i.geom::geography, :dist_threshold*1000) 
) a
ORDER BY userdata_id, dist_m ASC
) b
WHERE a.id=b.userdata_id
;

-- Fill in institutional data
UPDATE :tbl_user_data_raw a
SET institution_code=b.institution_code,
institution_name=b.institution_name
FROM institution b
WHERE a.institution_id=b.id
;

-- Save the threshold value to all records
UPDATE :tbl_user_data_raw
SET dist_threshold_km = :dist_threshold::double precision
;

/* UNDER CONSTRUCTION
-- Concatenate multiple institutions equally-distant to same observation
ALTER TABLE :tbl_user_data_raw
RENAME TO :tbl_user_data_raw_temp
;
CREATE TABLE :tbl_user_data_raw (LIKE :tbl_user_data_raw_temp INCLUDING ALL);

INSERT INTO :tbl_user_data_raw (
job,
user_id,
country_state_latlong,
country,
state_province,
latitude_verbatim,
longitude_verbatim,
latitude,
longitude,
dist_min_km,
dist_threshold_km,
institution_code,
institution_name,
is_cultivated_observation,
is_cultivated_observation_reason,
date_created,
geom
)
SELECT DISTINCT ON (
job,
user_id,
country_state_latlong,
country,
state_province,
latitude_verbatim,
longitude_verbatim,
latitude,
longitude,
dist_min_km,
dist_threshold_km,
institution_code,
institution_name,
is_cultivated_observation,
is_cultivated_observation_reason,
date_created,
geom
FROM :tbl_user_data_raw_temp


*/






