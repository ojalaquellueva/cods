#!/bin/bash

#########################################################################
# Purpose: echoes elapsed time since previous process
#########################################################################

elapsed=$(etime $prev); prev=`date +%s%N`
echoi $e " ($elapsed sec)"