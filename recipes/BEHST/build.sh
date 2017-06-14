#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

PREFIX=$HOME

cd $PREFIX/bin/

mkdir $PREFIX/../results/

mkdir $PREFIX/../temp/


sh project.sh $PREFIX/../data/pressto_LUNG_enhancers.bed DEFAULT_EQ DEFAULT_ET
