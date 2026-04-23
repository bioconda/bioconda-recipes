#!/bin/bash
set -xe

BEAST_DIR_SUFFIX="opt/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BEAST_DIR="$PREFIX/${BEAST_DIR_SUFFIX}"
mkdir -p $BEAST_DIR

# First copy the full release contents over
cp -r $SRC_DIR/beast2_full/* $BEAST_DIR

# Next, copy the package release contents into the full release directory
cp -r $SRC_DIR/beast2_base_package/* $BEAST_DIR
cp -r $SRC_DIR/beast2_app_package/* $BEAST_DIR

# Setup symlinks in conda "bin/" directory to the beast2 install directory
ln -s ../${BEAST_DIR_SUFFIX}/bin/{applauncher,beast,beauti,densitree,loganalyser,logcombiner,packagemanager,treeannotator} $PREFIX/bin
