#!/bin/bash

##############################################################
# Application parameters
# Check and change as needed
##############################################################

# Reference database for political division tables
DB_POLDIV="gnrs"		# Source db for world geom table

BASEDIR="/home/boyle/bien/cods"
APPNAME="CODS"

# Remove raw institution tables when done?
DROP_RAW='t'

# Tables to drop
# Only dropped if DROP_RAW='t'
RAW_TBLS="
ih
bcgi_raw
"

# Path to db_config.sh
# For production, keep outside app working directory & supply
# absolute path
# For development, if keep inside working directory, then supply
# relative path
# Omit trailing slash
db_config_path="${BASEDIR}/config"

# Path to general function directory
# If directory is outside app working directory, supply
# absolute path, otherwise supply relative path
# Omit trailing slash
#functions_path=""
functions_path="${BASEDIR}/src/includes"

# Path to data directory for database build
# Recommend call this "data"
# If directory is outside app working directory, supply
# absolute path, otherwise use relative path (i.e., no 
# forward slash at start).
# Recommend keeping outside app directory
# Omit trailing slash
data_base_dir="${BASEDIR}/data/db"
#data_base_dir="data"		 # Relative path

# Raw data files
data_raw_bcgi="BCGI_raw_20210225.csv"
data_raw_ih=""

# Makes user_admin the owner of the db and all objects in db
# If leave user_admin blank ("") then database will be owned
# by whatever user you use to run this script, and postgis tables
# will belong to postgres
USER_ADMIN="bien"		# Admin user

# Destination email for process notifications
# You must supply a valid email if you used the -m option
email="bboyle@email.arizona.edu"

# Short name for this operation, for screen echo and 
# notification emails. Number suffix matches script suffix
pname="Build ${APPNAME} database"

# General process name prefix for email notifications
pname_header_prefix="BIEN notification: process"