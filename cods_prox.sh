#!/bin/bash

#########################################################################
# Cultivated Observation Detection Service (CODS) batch application, 
# proximity algotithm
#  
# Purpose: Flags observations as potentially cultivated if they within
#	threshold distance of herbarium or botanical garden
#
# Usage: ./cods_prox.sh
#
# Requirements: 
# 	1. Table ih in db.schema vegbien.analytical_db
#		* this is temporary requirement until script direct import
#
# Authors: Brad Boyle (bboyle@email.arizona.edu)
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set basic parameters, functions and options
######################################################

# Enable the following for strict debugging only:
#set -e

# Trigger sudo password request. 
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
mkdir -p "$DIR/log" 
touch $glogfile

# Set includes directory path, relative to $DIR
includes_dir=$DIR"/includes"

# Load parameters, functions and get command-line options
#source "$includes_dir/startup_master.sh"

# Load parameters file
source "$DIR/params.sh"

# Load db configuration params
source "$db_config_path/db_config.sh"	

# Load functions 
source "$includes_dir/functions.sh"

# Set local directories to same as main
data_dir_local=$data_base_dir
data_dir=$data_base_dir
DIR_LOCAL=$DIR

###########################################################
# Get options
###########################################################

# Set defaults
infile=""	# Input file and path
outfile=""	# Output file and path
api="false"		# Assume not an api call
silent="false"	# off; sets both $e and $i to false if true
i="true"						# Interactive mode on by default
e="true"						# Echo on by default
appendlog="false"				# Append to existing logfile 

# psql default options
# User and password not set by default
# Must have passwordless authentication for these to work
opt_pgpassword=""	# Omit if not an api call
opt_user=""			# Omit if not an api call

# Optional threshold parameters
# Empty string: use default values supplied in params.sh
maxdist=""

while [ "$1" != "" ]; do
    case $1 in
        -a | --api )         	api="true"
                            	;;
        -f | --infile )        	shift
                                infile=$1
                                ;;
        -o | --outfile )       	shift
                                outfile=$1
                                ;;
        -d | --maxdist )       	shift
                                maxdist=$1
                                ;;
        -n | --nowarnings )		i="false"
        						;;
        -e | --echo )			e="true"
        						;;
        -s | --silent )			silent="true"
        						e="false"
        						i="false"
        						;;
        -v | --nullval )        shift
        						nullval="$1"
                            	;;
        -m | --mail )         	m="true"
                                ;;
        -a | --appendlog )		appendlog="true" 	# Start new logfile, 
        											# replace if exists
        						;;
         * )                     echo "ERROR: invalid option"; exit 1
    esac
    shift
done

#####################
# Validate options
#####################

# Input file (required)
if [[ "$infile" == "" ]]; then
	echo "ERROR: input file required"
	exit 1;
else
	# Check file exists
	if [ ! -f "$infile" ]; then
		echo "ERROR: file '$infile' does not exist"
		exit 1
	fi
fi

# Output file (optional)
# If not provided, name output file as inputfile basename plus
# "_cds_results" and save to same directory
if [[ ! "$outfile" == "" ]]; then
	# Check destination directory exists
	outdir=$(dirname "${outfile}")
	if [ ! -d "$outdir" ]; then
		echo "ERROR in outfile '$outfile': no such path"
		exit 1
	fi
else
	# Create outfile path
	outdir=$(dirname "${infile}")
	filename=$(basename -- "${infile}")
	ext="${filename##*.}"
	base="${filename%.*}"
	outfilename="${base}_cds_results.${ext}"
	outfile="${outdir}/${outfilename}"
fi

# Reset threshold parameter MAX_DIST if supplied
# Assume default to start (from params file)
dist_threshold=$DIST_THRESHOLD
if [[ ! "$maxdist" == "" ]]; then
	# Check positive integer
	if test "$maxdist" -gt 0 2> /dev/null ; then
		dist_threshold=$maxdist
	else
		echo "ERROR: Option -d/--maxdist must be a positive integer"
		exit 1
	fi
fi

# Set user and password for api access
# Parameters $USER and $PWD_USER set in config file params.sh
if  [ "$api" == "true" ]; then
	opt_pgpassword="PGPASSWORD=$PWD_USER"
	opt_user="-U $USER"
	
	# Turn off all echoes, regardless of echo options sent
	e="false"
	i="false"
fi

# Check email address in params if -m option chosen
if [ "$m" == "true" ] && [ "$email" == "" ]; then
	echo "ERROR: -m option used but no email in params file"
	exit 1;
fi

######################################################
# Custom confirmation message. 
# Will only be displayed if -s (silent) option not used.
######################################################

if [ "$i" == "true" ]; then

	# Current user
	curr_user="$(whoami)"

	# Reset confirmation message
	msg_conf="$(cat <<-EOF

	Run process '$pname' using the following parameters: 

	Current user:		$curr_user
	Input file:		$infile
	Output file:		$outfile
	Distance threshold:	$dist_threshold

EOF
	)"		
	confirm "$msg_conf"
fi

# Start time, send mail if requested and echo begin message
# Start timing & process ID
starttime="$(date)"
start=`date +%s%N`; prev=$start
pid=$$

if [[ "$m" == "true" ]]; then 
	source "${includes_dir}/mail_process_start.sh"	# Email notification
fi

if [ "$i" == "true" ]; then
	echoi $e ""; echoi $e "------ Process started at $starttime ------"
	echoi $e ""
fi

#########################################################################
# Main
#########################################################################

# Generate unique suffix by concatenating date in nanoseconds
# plus random integer for good measure
uniqid="$(date +%Y%m%d_%H%M%N)_${RANDOM}"	

# For testing only: all temp user data table have same name 
# so I don't have to delete a ton of tables
#uniqid="temp"

# Create uniquely names user data tables and job_id
tbl_user_data="user_data_prox_${uniqid}"
tbl_user_data_raw="${tbl_user_data}_raw"
job="job_${uniqid}"	

# echo "tbl_user_data=${tbl_user_data}"
# echo "tbl_user_data_raw=${tbl_user_data_raw}"
# echo "job=${job}"
# echo "db_config_path=${db_config_path}"
# echo "includes_dir=${includes_dir}"
# echo "DB=${DB}"
# echo "opt_pgpassword=${opt_pgpassword}"
# echo "opt_user=${opt_user}"

############################################
# Load raw data to table user_data
############################################

# Import the input file
echoi $e "Importing user data:"

# Create job-specific temp table to hold raw data
echoi $e -n "- Creating temp user data table \"$tbl_user_data_raw\"..."
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user -d $DB --set ON_ERROR_STOP=1 -q -v tbl_user_data_raw="${tbl_user_data_raw}" -f $DIR_LOCAL/sql/create_raw_data_temp.sql"
eval $cmd
source "$DIR/includes/check_status.sh"

# Import the file to tempoprary raw data table
# $nullas statement set as optional command line parameter
echoi $e -n "- Importing raw data to temp table..."
metacmd="\COPY ${tbl_user_data_raw} (country_state_latlong, country, state_province, latitude_verbatim, longitude_verbatim, user_id) FROM '${infile}' DELIMITER ',' CSV $HEADER $nullas "
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user -d $DB --set ON_ERROR_STOP=1 -q -c \"$metacmd\""
eval $cmd
source "$DIR/includes/check_status.sh"

# Validating geocoordinates
echoi $e -n "- Validating geocoordinates..."
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user  -d $DB --set ON_ERROR_STOP=1 -q -v tbl_user_data_raw=${tbl_user_data_raw} -f $DIR_LOCAL/sql/validate_latlong.sql"
eval $cmd
source "$DIR/includes/check_status.sh"

# Populate spatial column
echoi $e -n "- Populating geom..."
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user  -d $DB --set ON_ERROR_STOP=1 -q -v tbl_user_data_raw=${tbl_user_data_raw} -f $DIR_LOCAL/sql/populate_geom.sql"
eval $cmd
source "$DIR/includes/check_status.sh"

############################################
# Calculate proximity and flag records
############################################

echoi $e -n "Calculating proximity to biodiversity institutions..."
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user  -d $DB --set ON_ERROR_STOP=1 -q -v tbl_user_data_raw=${tbl_user_data_raw} -v dist_threshold=${dist_threshold} -f $DIR_LOCAL/sql/mindist.sql"
eval $cmd
source "$DIR/includes/check_status.sh"

############################################
# Export the results
############################################

echoi $e -n "Exporting results to file '$outfile'..."
metacmd="\COPY (SELECT id AS cods_id, user_id, country_state_latlong, country, state_province, latitude_verbatim, longitude_verbatim, latitude, longitude, dist_min_km, dist_threshold_km, institution_code, institution_name, is_cultivated_observation, is_cultivated_observation_reason FROM ${tbl_user_data_raw}) TO '${outfile}' CSV HEADER"
cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user -d $DB --set ON_ERROR_STOP=1 -q -c \"$metacmd\""
eval $cmd
echoi $i "done"

# Drop the temp user data table if requested
if [ "$DROP_USER_DATA_TEMP" == "true" ]; then
	echoi $e -n "Dropping temporary user data table..."
	sql="DROP TABLE $tbl_user_data_raw"
	cmd="$opt_pgpassword PGOPTIONS='--client-min-messages=warning' psql $opt_user -d $DB --set ON_ERROR_STOP=1 -q -c \"$sql\""
	eval $cmd
	source "$DIR/includes/check_status.sh"
fi

######################################################
# Report total elapsed time and exit if running solo
######################################################

source "$DIR/includes/finish.sh"

######################################################
# End script
######################################################