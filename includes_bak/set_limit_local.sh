#!/bin/bash

#########################################################################
# Purpose: Sets local limit parameter ($limit_local) based on global and
# local parameters
#########################################################################

if [ "$use_limit" == "true" ]; then
	if [ "$use_limit_local" == "false" ] && [ "$force_limit" != "true" ]; then
		limit_local="false"
	else
		limit_local="true"
	fi
else	# "$use_limit" == "false"
	if [ "$use_limit_local" == "true" ] && [ "$force_limit" != "true" ]; then
		limit_local="true"
	else
		limit_local="false"
	fi
fi
