#!/bin/bash
set -eu -o pipefail

#create target directory
PACKAGE_HOME=$PREFIX/share/$PKG_NAME
mkdir -p $PACKAGE_HOME

#create bin
BINARY_HOME=$PREFIX/bin
mkdir -p "$BINARY_HOME"

cd $SRC_DIR

JAR_NAME=GAMETES_2.1.jar

cp $JAR_NAME $PACKAGE_HOME/gametes.jar

cp $RECIPE_DIR/gametes.py ${BINARY_HOME}/gametes

chmod +x ${BINARY_HOME}/gametes





