#!/bin/bash

######################################################
# Confirm operation (interactive mode only), start
# timer & send confirmation email if requested
######################################################

if [ -z ${suppress_main+x} ]; then suppress_main='false'; fi

if [[ "$i" = "true" ]] && [[ "$suppress_main" = "false" ]]; then 
	# Construct confirmation message
	# Displayed in interactive mode in effect
	startup_msg="Run process \""$pname"\"?"

	# Display options as well if provided
	if ! [[ -z "$startup_msg_opts" || "$startup_msg_opts" == "" ]]; then 
		startup_msg="$(cat <<-EOF
		${startup_msg} with following options:
		
		${startup_msg_opts}
EOF
		)"
	fi

	confirm "$startup_msg";
fi

# Start timing & process ID
start=`date +%s%N`; prev=$start
pid=$$

# Send notification email if this option set
if [[ "$m" = "true" ]]; then 
	source "$DIR/includes/mail_process_start.sh"	# Email notification
fi

echoi $e ""; echoi $e "------ Begin process '$pname' ------"
echoi $e ""