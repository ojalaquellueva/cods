-- ----------------------------------------------------------
-- Validate that verbatim coordinates are numeric and in range,
-- the copy double precision latitude, longitude columns
-- The prevents throwing errors
--
-- Requires parameters:
--	$tbl_user_data_raw --> :tbl_user_data_raw 
-- Requires custom function: 
-- 	isnumeric()
-- ----------------------------------------------------------

-- Check not numeric
UPDATE :tbl_user_data_raw
SET latitude=
CASE 
WHEN isnumeric(latitude_verbatim) THEN CAST(latitude_verbatim AS double precision)
ELSE NULL
END,
longitude=
CASE 
WHEN isnumeric(longitude_verbatim) THEN CAST(longitude_verbatim AS double precision)
ELSE NULL
END
;
UPDATE :tbl_user_data_raw
SET 
is_cultivated_observation_reason='[coordinates not numeric]',
latitude=NULL,
longitude=NULL,
is_cultivated_observation=NULL
WHERE latitude IS NULL OR longitude IS NULL
;

-- Check out of range
UPDATE :tbl_user_data_raw
SET 
is_cultivated_observation_reason='[coordinates out of range]',
latitude=NULL,
longitude=NULL,
is_cultivated_observation=NULL
WHERE (latitude>90 OR latitude<-90)
OR (longitude>180 OR longitude<-180)
;