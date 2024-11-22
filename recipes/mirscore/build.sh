#!/bin/bash
set -eu -o pipefail

# specify and create /bin/ directory
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

# make executables 
chmod +x $SRC_DIR/miRScore
chmod +x $SRC_DIR/hairpinHelper

# Install the scripts
cp $SRC_DIR/miRScore $BINDIR
cp $SRC_DIR/hairpinHelper $BINDIR
