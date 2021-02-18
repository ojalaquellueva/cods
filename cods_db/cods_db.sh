#!/bin/bash

#########################################################################
# Purpose: Creates and populates CODS database 
#
# Usage:	./cds_db.sh
#
# Authors: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 11 Mar 2020
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set basic parameters, functions and options
######################################################

# Enable the following for strict debugging only:
#set -e

# Trigger sudo password request
sudo pwd >/dev/null

# The name of this file. Tells sourced scripts not to reload general  
# parameters and command line options as they are being called by  
# another script. Allows component scripts to be called individually  
# if needed
master=`basename "$0"`

# Get working directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Start logfile
export glogfile="$DIR/log/logfile_"$master".txt"
sudo mkdir -p "$DIR/log" 
sudo touch $glogfile

# Set includes directory path, relative to $DIR
includes_dir=$DIR"/../includes"

# Load parameters, functions and get command-line options
source "$includes_dir/startup_master.sh"

# # Set process name and confirm operation
# pname="Build centroid validation database $DB"
# source "$includes_dir/confirm.sh"

# Set local directories to same as main
data_dir_local=$data_base_dir
data_dir=$data_base_dir
DIR_LOCAL=$DIR

######################################################
# Custom confirmation message. 
# Will only be displayed if -s (silent) option not used.
######################################################

if [ "$i" == "true" ]; then

	# Current user
	curr_user="$(whoami)"

	# Admin user message
	user_admin_disp=$curr_user
	if [[ "$USER_ADMIN" != "" ]]; then
		user_admin_disp="$USER_ADMIN"
	fi

	# Reset confirmation message
	msg_conf="$(cat <<-EOF

	Run process '$pname' using the following parameters: 

	DB name:		$DB
	Data directory:		$data_dir
	Current user:		$curr_user
	Admin user/db owner:	$user_admin_disp

EOF
	)"		
	confirm "$msg_conf"
fi

# Start time, send mail if requested and echo begin message
source "$includes_dir/start_process.sh"  

#########################################################################
# Main
#########################################################################


############################################
# Create database, add functions & extensions
############################################

# Check if db already exists
# Warn to drop manually. This is safer.
if psql -lqt | cut -d \| -f 1 | grep -qw "$DB"; then
	# Reset confirmation message
	msg="Database '$DB' already exists! Please drop first."
	echo $msg; exit 1
fi

echoi $e -n "Creating database '$DB'..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "CREATE DATABASE $DB" 
source "$includes_dir/check_status.sh"  

echoi $e "Installing extensions:"

echoi $e -n "- fuzzystrmatch..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS fuzzystrmatch;
CREATE EXTENSION fuzzystrmatch;
EOF
echoi $i "done"

# For generating unaccented versions of text
echoi $e -n "- unaccent..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS unaccent;
CREATE EXTENSION unaccent;
EOF
echoi $i "done"

# POSTGIS
echoi $e -n "- postgis..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS postgis;
CREATE EXTENSION postgis;
EOF
echoi $i "done"

# Functions
echoi $e -n "Installing custom functions..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB --set ON_ERROR_STOP=1 -q -f $DIR/sql/functions.sql
source "$includes_dir/check_status.sh"  

############################################
# Build core tables
############################################

echoi $e -n "Creating core tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_core_tables.sql >/dev/null
source "$includes_dir/check_status.sh"  

############################################
# Import biodiversity institution data
############################################

echoi $e "Importing reference data:"
echoi $e "- Importing table ih from BIEN DB (temp hack!):"

# Dump table from source databse
echoi $e -n "-- Exporting dumpfile..."
dumpfile="/tmp/ih.sql"
sudo -Hiu postgres pg_dump --no-owner -t "analytical_db.ih" "vegbien" > $dumpfile
source "$includes_dir/check_status.sh"	

# Correct schema references if $SCH_GEOM<>"public"
# Will screw up the dumpfile if source schema is already "public"
echoi $e -n "-- Correcting schema references in dumpfile..."
sed -i -e "s/analytical_db./public./g" $dumpfile
sed -i -e "s/Schema: analytical_db;/Schema: public;/g" $dumpfile
sed -i -e "s/ analytical_db./ public./g" $dumpfile
source "$includes_dir/check_status.sh"	

# Import table from dumpfile to target db & schema
echoi $e -n "-- Importing table from dumpfile..."
PGOPTIONS='--client-min-messages=warning' psql -q --set ON_ERROR_STOP=1 $DB < $dumpfile >/dev/null
source "$includes_dir/check_status.sh"	

echoi $e -n "-- Removing dumpfile..."
rm $dumpfile
source "$includes_dir/check_status.sh"	

############################################
# Load & index institutions table
############################################

echoi $e "Preparing table \"institution\":"

echoi $e -n "- Loading table ..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB --set ON_ERROR_STOP=1 -q -f $DIR/sql/institution_load.sql
source "$includes_dir/check_status.sh"  

echoi $e -n "- Populating geometry column..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB --set ON_ERROR_STOP=1 -q -f $DIR/sql/institution_populate_geom.sql
source "$includes_dir/check_status.sh"  

############################################
# Clean up
############################################

if [ "$DROP_RAW" == "t" ]; then
	echoi $e "Dropping raw data tables:"
	for tbl_raw in $RAW_TBLS; do
		echoi $e -n "- ${tbl_raw}..."
		sql="DROP TABLE IF EXISTS ${tbl_raw}"
		sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB --set ON_ERROR_STOP=1 -q -c "$sql" 
		source "$includes_dir/check_status.sh" 
	done
fi 

############################################
# Alter ownership and permissions
############################################

source "$DIR/setp.sh"

######################################################
# Report total elapsed time and exit
######################################################

if [ "$i" == "true" ]; then
	source "$includes_dir/finish.sh"
fi
