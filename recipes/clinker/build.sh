#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $PACKAGE_HOME

# Copy files over into $PACKAGE_HOME
cp -aR * $PACKAGE_HOME

DEST_FILE=$PACKAGE_HOME/clinker
cp $RECIPE_DIR/clinker-wrapper.sh $DEST_FILE
chmod +x $DEST_FILE
ln -s $DEST_FILE $PREFIX/bin



