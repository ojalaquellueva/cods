#!/bin/bash

#########################################################################
# Purpose: Gets command line switches and sets options accordingly
#
# Keeping this in separate script allows it to be used by individual
# pipeline scripts run on their own
#########################################################################


###########################################################
# Get options
#   -n  No confirm. All interactive warnings suppressed
#   -s  Silent mode. Suppresses screen echo.
#   -m	Send email notification. Must supply valid email 
#		in params file.
# 	-d 	Database to connect to (no default)
#	-c	Schema to connect to (no default)
#	-a	Append to existing logfile (=$glogfile). If not 
#		provided, default is start new (replace old if exists)
###########################################################

# Set defaults
i="true"						# Interactive mode on by default
e="true"						# Echo on by default
appendlog="false"				# Append to existing logfile 

# Get options
while [ "$1" != "" ]; do
    case $1 in
        -n | --nowarnings )		i="false"
        						;;
        -s | --silent )			e="false"
        						i="false"
        						;;
        -m | --mail )         	m="true"
                                ;;
        -d | --database )       db="$2"
        						shift
                                ;;
        -c | --schema )         sch="$2"
        						shift
                                ;;
        -a | --appendlog )		appendlog="true" 	# Start new logfile, 
        											# replace if exists
        						;;
        * )                     echo "invalid option!"; exit 1
    esac
    shift
done


# Replace global logfile if defined and appendlog=false
if [[ "$appendlog" == "false" ]]; then
	rm -f $glogfile; touch $glogfile
elif [ -f $glogfile ]; then
    touch $glogfile
fi
