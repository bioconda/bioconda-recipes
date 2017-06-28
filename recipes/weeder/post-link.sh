#!/bin/bash

echo "Downloading and installing Weeder frequency files..."

# Directory to store FreqFiles
TGT="$PREFIX/share/weeder2"

# Cargo port url
CARGO_URL=http://depot.galaxyproject.org/software/

# Download and unpack
TARBALL=${PKG_NAME}_${PKG_VERSION}_src_all.tar.gz
curl -L ${CARGO_URL}/${PKG_NAME}/$TARBALL -o $TGT/$TARBALL

# Extract FreqFiles directory
(cd $TGT && tar xvzf $TARBALL FreqFiles)

# Remove tarball
rm $TGT/$TARBALL
