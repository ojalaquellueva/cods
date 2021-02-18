#!/bin/bash

##############################################################
# Application parameters
# Check and change as needed
##############################################################

##########################
# Paths, adjust according  
# to your installation
##########################

# Application base directory (=parent of repo directory src/)
# Critical! Most other paths depend on this parameter
BASEDIR="/home/boyle/bien/cods"

# Path to db_config.sh
# For production, keep outside app directory & supply absolute path
# Omit trailing slash
db_config_path="${BASEDIR}/config"

# Relative data directory name
# CDS will look here inside app directory for user input
# and will write results here, unless $data_dir_local_abs
# is set (next parameter)
# Omit trailing slash
data_base_dir="../data"		

# Absolute path to data directory
# Use this if data directory outside root application directory
# Comment out to use $data_base_dir (relative, above)
# Omit trailing slash
data_dir_local_abs="${BASEDIR}/data"
#data_dir_local_abs="/home/boyle/bien3/repos/cds/data/user_data"

# For backward-compatibility
data_dir_local=$data_dir_local_abs

######################################
# Distance threshold
#
# Set maximum radius for biodiversity 
# institution threshold, within which
# an observation is labelled potentially
# cultivated
######################################

# Maximum distance (km) to institution centroid
DIST_THRESHOLD=3

#############################################################
# Normally shouldn't have to change remaining parameters
#############################################################

##########################
# Clean-up parameters
##########################

# Clear all data from main user_data table
# For development only
# Any value other than true, does nothing
# TURN OFF DURING PRODUCTION!
CLEAR_USER_DATA="false"

# Drop temporary user data table when done
DROP_USER_DATA_TEMP="false"

##########################
# Default input/output file names
##########################

# Default name of the raw data file to be imported. 
# This name will be used if no file name supplied as command line
# parameter. Must be located in the user_data directory
# submitted_filename="cods_submitted.csv" 

# Default name of results file
# results_filename="cods_results.csv"

##########################
# Import parameters
##########################

# Set = to 'HEADER' if file has header, otherwise empty string ("")
# Make this option command line parameter as well
HEADER="HEADER"

##########################
# Input subsample parameters
##########################

# 't' to limit number of records imported (for testing)
# 'f' to run full import
# recordlimit ignored if use_limit='f'
use_limit='f'
recordlimit=100000000000

##########################
# Display/notification parameters
##########################

# Destination email for process notifications
# You must supply a valid email if you used the -m option
email="bboyle@email.arizona.edu"

# Short name for this operation, for screen echo and 
# notification emails. Number suffix matches script suffix
pname="CODS"
pname_key="CODS (keyword search)"
pname_local=$pname
pname_local_key=$pname_key

# General process name prefix for email notifications
pname_header_prefix="BIEN notification: process"
