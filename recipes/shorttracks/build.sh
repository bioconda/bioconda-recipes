#!/bin/bash
set -eu -o pipefail

# specify and create /bin/ directory
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

# make executable
chmod +x $SRC_DIR/ShortTracks

# Install the script
cp $SRC_DIR/ShortTracks $BINDIR
