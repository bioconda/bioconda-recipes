#!/bin/bash
set -xe

# Copies full beast2 distribution to opt/
BEAST_DIR_SUFFIX="opt/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BEAST_DIR="$PREFIX/${BEAST_DIR_SUFFIX}"

mkdir -p $BEAST_DIR
cp -r $SRC_DIR/* $BEAST_DIR

ln -s ../${BEAST_DIR_SUFFIX}/bin/{applauncher,beast,beauti,densitree,loganalyser,logcombiner,packagemanager,treeannotator} $PREFIX/bin
