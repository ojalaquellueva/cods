INSERT INTO institution (
source,
institution_code,
institution_name,
institution_type,
country,
state_province,
latitude,
longitude
)
SELECT
'IH',
acronym,
"*NamOrganisation",
'Herbarium',
country,
state_province,
lat,
long
FROM ih
;

INSERT INTO institution (
source,
institution_code,
institution_name,
institution_type,
country,
state_province,
latitude,
longitude
)
SELECT
'BCGI',
CONCAT_WS('_', 'bcgi', "GardenID"),
"Institution",
'Botanic garden',
country_name,
NULL,
"new_Latitude",
"new_Longitude"
FROM bcgi_raw
WHERE "new_Latitude" IS NOT NULL AND "new_Longitude" IS NOT NULL
;
;
