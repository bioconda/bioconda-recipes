#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

cd $PREFIX/bin

./project.sh ../data/pressto_BLOOD_enhancers.bed DEFAULT_EQ DEFAULT_ET
./project.sh ../data/vista_LIMB_sorted.bed DEFAULT_EQ DEFAULT_ET