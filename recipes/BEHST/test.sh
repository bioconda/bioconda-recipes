#!/bin/bash
#
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

# download a minimal data set for testing
./download_behst_data.sh ~/thisBEHSTdataFolder --small

# runs in a minute or two
./besht.py ~/thisBEHSTdataFolder/pressto_LIVER_enhancers.bed ~/thisBEHSTdataFolder