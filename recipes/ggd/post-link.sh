#!/bin/bash
set -eo pipefail -o nounset

## Organize required conda channels
conda config --add channels defaults
conda config --add channels ggd-genomics
conda config --add channels bioconda
conda config --add channels conda-forge

## initialize local metadata
cat << EOF > initialize_metadata.py
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
python initialize_metadata.py 
rm initialize_metadata.py
