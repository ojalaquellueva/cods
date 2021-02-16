#!/bin/bash

#########################################################################
# Purpose: Echoes completion time at end of script, and send notification  
# email, if requested
#
# Required parameters (from calling script):
#	$start		Time at start of operation
#	$m			Send notification email ("true","false")
#	$pid		Process ID of master script
#	$pname_header	Full process name, for email header
#	#e			Interactive mode ("true","false")
#
# Requires functions:
#	echoi
#########################################################################

# Get time elapsed since start
elapsed=$(etime $start)

# Send notification if requested
if [[ "$m" = "true" ]]; then
	endtime=`date`
	subject="Process "$pname" completed"
	msg="Process PID "$pid" completed: $endtime"
	echo "$msg" | mail -s "$subject" $email
fi

echoi $e "" 
echoi $e "------ Process '$pname' completed in $elapsed seconds ------"
echoi $e ""
exit 0