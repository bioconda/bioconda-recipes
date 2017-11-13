#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

# Create destination directories
mkdir -p $PACKAGE_HOME

# Copy over files
cp -aR bin lib bpipe.config templates html $PACKAGE_HOME

# Link out files
ln -s $PACKAGE_HOME/bin/* $PREFIX/bin
