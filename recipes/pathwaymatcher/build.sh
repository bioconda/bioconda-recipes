#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $PACKAGE_HOME
mkdir -p $BINARY_HOME

ln -s $PACKAGE_HOME $PREFIX/share/$PKG_NAME

# Copy files into $PACKAGE_HOME
cp -R ./* $PACKAGE_HOME/

# Create wrapper
SOURCE_FILE=$RECIPE_DIR/pathwaymatcher.py
DEST_FILE=$PACKAGE_HOME/pathwaymatcher

cp $SOURCE_FILE $DEST_FILE
# We also copy pathwaymatcher.py as it is
cp $SOURCE_FILE $PACKAGE_HOME/pathwaymatcher.py

chmod +x $DEST_FILE

ln -s $DEST_FILE $BINARY_HOME
ln -s $PACKAGE_HOME/pathwaymatcher.py $BINARY_HOME
