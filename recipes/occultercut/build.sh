#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
#
set -eu -o pipefail

make

#mkdir -p $PREFIX/bin
#cp OcculterCut $PREFIX/bin
