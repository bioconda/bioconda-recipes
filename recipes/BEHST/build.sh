#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

echo $(pwd)
echo $(ls)

cd ./bin/

mkdir ../results/

mkdir ../temp/


sh project.sh ../data/pressto_LUNG_enhancers.bed DEFAULT_EQ DEFAULT_ET
