#!/bin/bash
#
# NOTE: only install ngs-sdk as this is the only requirement for
# sratools
#

./configure --prefix=$PREFIX --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk
make -C ngs-sdk install

