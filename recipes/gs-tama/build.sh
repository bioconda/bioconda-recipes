#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eu -o pipefail

cd $SRC_DIR
mkdir -p $PREFIX/bin/
for i in $(ls); do cp -r $i $PREFIX/bin/; done

#cd $SRC_DIR
#mkdir -p $PREFIX/bin/
#cp tama_collapse.py $PREFIX/bin/
#cp tama_merge.py $PREFIX/bin/
#for i in $(find tama_go/ -type f -executable); do cp $i $PREFIX/bin/; done  
