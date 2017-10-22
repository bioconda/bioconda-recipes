#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/* $PREFIX/bin
cd $PREFIX/bin

./download_behst_data.sh ~/thisBEHSTdataFolder