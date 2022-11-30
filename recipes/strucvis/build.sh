#!/bin/bash
set -eu -o pipefail

# specify and create /bin/ directory
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

# make executable
chmod +x $SRC_DIR/strucVis

# Install the script and its README
cp $SRC_DIR/strucVis $BINDIR
cp $SRC_DIR/README $BINDIR
