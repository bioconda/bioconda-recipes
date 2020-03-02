#!/bin/bash
set -eo pipefail -o nounset

## initialize local metadata
"${PREFIX}/bin/python" -c "$( cat <<'EOF'
"""
Set up initial ggd local metdata
"""
from ggd import utils

## Update local genomic metadata files
utils.update_genome_metadata_files()

##Update local channeldata.json metadata file
utils.update_channel_data_files("genomics")

## Get species
utils.get_species(update_files=True)

## get channels
channels = utils.get_ggd_channels()

## get channel data
for x in channels:
    utils.get_channel_data(x)

## Initialize pkg metadata tracking
utils.update_installed_pkg_metadata()
EOF
)" >> "${PREFIX}/.messages.txt" 2>&1

echo """

NOTE: Please run the following command to add the required conda channels for GGD: """ >> "${PREFIX}/.messages.txt" 2>&1  

echo """    conda config --add channels defaults
    conda config --add channels ggd-genomics
    conda config --add channels biconda
    conda config --add channels conda-forge """ >> "${PREFIX}/.messages.txt" 2>&1

