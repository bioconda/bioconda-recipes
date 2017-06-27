#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o pipefail -o errexit
set -o xtrace

cd $PREFIX/bin

./project.sh --test
