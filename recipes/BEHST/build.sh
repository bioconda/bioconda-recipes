#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

cd $SRC_DIR/bin

./download_behst_data.sh