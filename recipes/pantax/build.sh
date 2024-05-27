#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cd $SRC_DIR/PanTax
    cp $SRC_DIR/PanTax/* $PREFIX
else
    PYTHON=${PYTHON:-$(which python)}
    $PYTHON -m pip install . -vv --no-dependencies
    cd $SRC_DIR/pantax
    chmod +x pantax
    cp $SRC_DIR/pantax/pantax ${PREFIX}/bin
    cp $SRC_DIR/pantax/*sh ${PREFIX}/bin
    cd $SRC_DIR/tools
    chmod +x vg
    cd fastix
    cargo install fastix --root ./
    mkdir -p ${PREFIX}/bin/tools
    cp $SRC_DIR/tools/fastix/bin/fastix ${PREFIX}/bin/tools
    cp $SRC_DIR/tools/vg ${PREFIX}/bin/tools
fi
