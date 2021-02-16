#!/bin/bash

#########################################################################
# Purpose: Loads parameters, functions & issues startup messages
#########################################################################

# Get this directory
thisdir="${BASH_SOURCE%/*}"

source $thisdir"/get_params.sh"	# Parameters, files and paths
source $thisdir"/functions.sh"	# Load functions file(s)
source $thisdir"/get_options.sh"	# Get & set command line options

