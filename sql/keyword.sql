-- ----------------------------------------------------------
-- Flag potentially cultivated observations by keyword
--
-- Requires parameter:
--	$tbl_user_data_raw --> :tbl_user_data_raw (job-specific temp table)
-- ----------------------------------------------------------

UPDATE :tbl_user_data_raw
SET description_unaccent=unaccent(description)
;

-- This query will be slow
-- Initial wild card prevents use of indexes
update :tbl_user_data_raw
set
is_cultivated_observation=1,
is_cultivated_observation_reason='Keywords in locality'
WHERE
description_unaccent ILIKE '%cultivated%' OR
description_unaccent ILIKE '%cultivad%' OR
description_unaccent ILIKE '%planted%' OR
description_unaccent ILIKE '%sembrad%' OR
description_unaccent ILIKE '%ornamental%' OR
description_unaccent ILIKE '%garden%' OR
description_unaccent ILIKE '%jardin%' OR
description_unaccent ILIKE '%jardim%' OR
description_unaccent ILIKE '%plantation%' OR
description_unaccent ILIKE '%plantacion%' OR
description_unaccent ILIKE '%plantacao%' OR
description_unaccent ILIKE '%campus%' OR 
description_unaccent ILIKE '%urban%' OR
description_unaccent ILIKE '%greenhouse%' OR
description_unaccent ILIKE '%invernadero%' OR
description_unaccent ILIKE '%arboretum%' OR
description_unaccent ILIKE '%farm%' OR
description_unaccent ILIKE '%corn field%'
;