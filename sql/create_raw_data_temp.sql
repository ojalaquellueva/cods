-- ----------------------------------------------------------
-- Create raw user data table
--
-- Requires parameter:
--	$tbl_user_data_raw --> :tbl_user_data_raw (job-specific temp table)
-- ----------------------------------------------------------

-- Create job-specific raw data table
DROP TABLE IF EXISTS :tbl_user_data_raw;
CREATE TABLE :tbl_user_data_raw (LIKE user_data_prox INCLUDING ALL);

