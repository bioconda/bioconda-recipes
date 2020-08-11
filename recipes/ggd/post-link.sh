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
mkdir -m u=rwx -p "$PREFIX/share/ggd_info/noarch" 
utils.update_installed_pkg_metadata()
EOF

)" >> "${PREFIX}/.messages.txt" 2>&1


