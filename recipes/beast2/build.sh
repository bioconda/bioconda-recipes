#!/bin/bash
set -xe

BEAST_DIR_SUFFIX="opt/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
BEAST_DIR="$PREFIX/${BEAST_DIR_SUFFIX}"

mkdir -p $BEAST_DIR

# Copy full beast2 installation directory
cp -r $SRC_DIR/beast/* $BEAST_DIR

# Setup symlinks in conda "bin/" directory to the beast2 install directory
ln -f -s ../${BEAST_DIR_SUFFIX}/bin/{applauncher,beast,beauti,densitree,loganalyser,logcombiner,packagemanager,treeannotator} $PREFIX/bin

# Create a BEAST package manager layout for the bundled BEAST.base and BEAST.app
# packages so the launcher scripts can discover them via BEAST_PACKAGE_PATH
# without copying them into $HOME/.beast at first launch. $HOME may be read-only
# in containerised environments (e.g. Singularity, Galaxy), which would otherwise
# make BEAST fail with ClassNotFoundException: beastfx.app.beast.BeastMain.
# Relative symlinks are used so the layout survives prefix relocation.
for pkg in BEAST.base BEAST.app; do
  mkdir -p "${BEAST_DIR}/packages/${pkg}/lib"
  ln -s ../../../lib/packages/${pkg}.jar "${BEAST_DIR}/packages/${pkg}/lib/${pkg}.jar"
  ln -s ../../lib/packages/${pkg}.version.xml "${BEAST_DIR}/packages/${pkg}/version.xml"
done
