#!/bin/bash

#########################################################################
# Download Index Herbariorum data from IH API and save
# to data directory
#########################################################################

echo "Downloading IH data:"

echo -n "- institutions..."
curl -o data/ih_institutions.json 'http://sweetgum.nybg.org/science/api/v1/institutions'
echo "done"
