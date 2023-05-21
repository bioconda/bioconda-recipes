#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

# Copy files into $PACKAGE_HOME
cp -R * $PACKAGE_HOME

# Link binaries into global bin directory
ln -s $PACKAGE_HOME/bin/{2bwt-builder,soapsplice} $PREFIX/bin
