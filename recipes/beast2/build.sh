#!/bin/bash
set -xe

BEAST_DIR_SUFFIX="opt/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BEAST_DIR="$PREFIX/${BEAST_DIR_SUFFIX}"
mkdir -p $BEAST_DIR

# Copy full beast2 installation directory
cp -r $SRC_DIR/beast2/* $BEAST_DIR

# Setup symlinks in conda "bin/" directory to the beast2 install directory
ln -s ../${BEAST_DIR_SUFFIX}/bin/{applauncher,beast,beauti,densitree,loganalyser,logcombiner,packagemanager,treeannotator} $PREFIX/bin
