#!/bin/sh
set -e

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-$PKG_VERSION-$PKG_BUILDNUM"
echo "  - RECIPE_DIR = $RECIPE_DIR"
echo "  - SHARE_DIR  = $SHARE_DIR"
  
# Install Perl files
chmod +x bin/*
mkdir -p "${PREFIX}/bin" "${SHARE_DIR}/refs"
mv bin/* "${PREFIX}/bin/"

# Install Python lab
if [ -e "setup/build.sh" ]; then
  echo " * Installing Python scripts"
  source setup/build.sh
else
  echo " * Skipping Python setup: this release does not include new Python scripts."
fi
#mv db/* "${PREFIX}/db/"
#cp -r doc/* "${PREFIX}/share/doc/dadaist2/"

