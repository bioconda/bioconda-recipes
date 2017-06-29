#!/bin/bash

set -e -x -o pipefail

binaries="\
mvicuna \
"

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $BINARY_HOME

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

if [ "$(uname)" == "Darwin" ]; then
    echo "Copying in *.dylib for OSX"
    mkdir -p $PREFIX/lib/
    # store the dylib with the binary (with custom name) so it does not
    # collide with the dylibs provided by libgcc
    #cp $SRC_DIR/mvicuna/MacOSX/*.dylib $PACKAGE_HOME
    #mv $PACKAGE_HOME/libgomp.1.dylib $PACKAGE_HOME/libgomp_custom.1.dylib
    cp $SRC_DIR/mvicuna/MacOSX/mvicuna $PACKAGE_HOME
    #install_name_tool -change '@executable_path/libgomp.1.dylib' "@executable_path/libgomp_custom.1.dylib" $PACKAGE_HOME/mvicuna
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    cd $SRC_DIR/mvicuna/src
    make
    for i in $binaries; do cp $SRC_DIR/mvicuna/bin/$i $PACKAGE_HOME; done
fi

cd $PACKAGE_HOME && chmod +x mvicuna

# create links for either common name
ln -s $PACKAGE_HOME/mvicuna $PREFIX/bin/mvicuna