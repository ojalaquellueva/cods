-- ----------------------------------------------------------
-- Populate point geometry column in temp user data table
--
-- Requires parameter:
--	$tbl_user_data_raw --> :tbl_user_data_raw batch-specific temp table)
-- ----------------------------------------------------------

-- Create job-specific raw data table
UPDATE :tbl_user_data_raw
SET geom = ST_SetSRID(ST_MakePoint(
longitude::double precision, 
latitude::double precision
), 4326)
;
