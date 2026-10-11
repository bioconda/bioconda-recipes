#!/bin/bash

# Install package into the share directory to allow for unit tests to be run.
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${SHARE_DIR}"
mkdir -p "${SHARE_DIR}/bin"
mkdir -p "${PREFIX}/bin"

# Copy across unit tests and python scripts
cp -rf unit-tests "${SHARE_DIR}"

2to3 -wn scripts/*.py
2to3 -wn source/*.py

sed -i.bak '1s/^\.7//' source/ExpressBetaDiversity.cpp
rm -f source/*.bak

# Build the binary
cd source
make -j"${CPU_COUNT}"

# Move built binary across to the shared bin and symlink it
cd ../bin
install -v -m 0755 ExpressBetaDiversity "${SHARE_DIR}/bin"

# Link the binary
ln -sf ${SHARE_DIR}/bin/ExpressBetaDiversity "${PREFIX}/bin"
chmod +x ${PREFIX}/bin/ExpressBetaDiversity

# Copy across python scripts
cd ../scripts
install -v -m 0755 AbstractPlot.py convertToEBD.py convertToFullMatrix.py pcoaPlot.py "${PREFIX}/bin"
