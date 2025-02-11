#!/bin/bash
set -eu -o pipefail

#######################
### DEBUGGING START ###
#######################

pwd -P

echo ""

find

echo ""

which gcc

#####################
### DEBUGGING END ###
#####################


cmake -DHTSLIB_DIR=htslib
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
