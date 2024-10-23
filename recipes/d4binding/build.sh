#!/bin/bash -e

set -x

cp $RECIPE_DIR/build_htslib.sh d4-hts/build_htslib.sh

cd d4binding 
./install.sh PREFIX="${PREFIX}"
