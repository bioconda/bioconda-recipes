#!/bin/sh
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#

set -eu -o pipefail

make clean
make probcons

# install probcons as probconsRNA to not conflict with the probcons package
mkdir -p "${PREFIX}/bin"
cp probcons "${PREFIX}/bin/probconsRNA"
