#!/bin/bash

SHARE_DIR=$PREFIX/share/$PKG_NAME
mkdir -p $SHARE_DIR
mkdir -p $PREFIX/bin

# Copy repo to share
cp -r . $SHARE_DIR/

# Ensure internal scripts are executable
chmod +x $SHARE_DIR/strainify
chmod +x $SHARE_DIR/*.py
chmod +x $SHARE_DIR/*.sh

# Create the global wrapper
ln -s $SHARE_DIR/strainify $PREFIX/bin/strainify