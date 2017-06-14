#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

PREFIX=.

cd $PREFIX/bin/

mkdir $PREFIX/../results/

mkdir $PREFIX/../temp/

sh project.sh ../data/pressto_BLOOD_enhancers.bed DEFAULT_EQ DEFAULT_ET

sh project.sh ../data/vista_LIMB_sorted.bed DEFAULT_EQ DEFAULT_ET
