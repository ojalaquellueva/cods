-- -----------------------------------------------------------------
-- Creates raw data table specific to source
-- -----------------------------------------------------------------

DROP TABLE IF EXISTS bcgi_raw;
CREATE TABLE bcgi_raw (
"GardenID" text,
"Institution" text,
"Address1" text,
"Address2" text,
"City" text,
"State" text,
"PostalCode" text,
"CountryCode" text,
"country_name" text,
"InstitutionType" text,
"original_Latitude" text,
"original_Longitude" text,
"verifiy_coords" text,
"new_Latitude" numeric default null,
"new_Longitude" numeric default null,
"new-old" text,
"geocode-old" text,
"geocode_lat" text,
"geocode_lon" text,
"geocode_addr-old" text,
"geocode_addr_lat" text,
"geocode_addr_lon2" text,
"geonameid" text,
"geoname" text,
"diff3" text,
"citylat" text,
"citylon" text,
"diff4" text,
"citystatelat" text,
"citystatelon" text,
"statelat" text,
"statelon" text,
"matchtype" text,
"matchtype_citystate" text,
"address" text
);