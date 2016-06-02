#!/bin/bash

set -e -x -o pipefail

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
    cp $SRC_DIR/V-Phaser-2.0/MacOSX/*.dylib $PACKAGE_HOME
    mv $PACKAGE_HOME/libgomp.1.dylib $PACKAGE_HOME/libgomp_custom.1.dylib
    cp $SRC_DIR/V-Phaser-2.0/MacOSX/variant_caller $PACKAGE_HOME
    install_name_tool -change '@executable_path/libgomp.1.dylib' "@executable_path/libgomp_custom.1.dylib" $PACKAGE_HOME/variant_caller
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    cp $SRC_DIR/V-Phaser-2.0/linux64/variant_caller $PACKAGE_HOME
fi

cd $PACKAGE_HOME && chmod +x variant_caller

# create links for either common name
ln -s $PACKAGE_HOME/variant_caller $PREFIX/bin/variant_caller
ln -s $PACKAGE_HOME/variant_caller $PREFIX/bin/vphaser2