UPDATE institution
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);