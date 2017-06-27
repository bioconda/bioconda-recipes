#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

PREFIX=.

cd $PREFIX/bin/


./download_behst_data.sh
