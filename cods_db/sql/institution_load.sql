INSERT INTO institution (
institution_code,
institution_name,
institution_type,
country,
state_province,
latitude,
longitude
)
SELECT
acronym,
"*NamOrganisation",
'herbarium',
country,
state_province,
lat,
long
FROM ih
;