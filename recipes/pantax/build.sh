#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cd $SRC_DIR/PanTax
    cp $SRC_DIR/PanTax/* $PREFIX
else
    cd $SRC_DIR/pantax
    chmod +x pantax
    cp $SRC_DIR/pantax/pantax ${PREFIX}/bin
    cp $SRC_DIR/pantax/*sh ${PREFIX}/bin
    cp $SRC_DIR/pantax/*py ${PREFIX}/bin
    cd $SRC_DIR/tools
    chmod +x vg
    cd fastix
    cargo install fastix --root ./
    mkdir -p ${PREFIX}/bin/tools
    cp $SRC_DIR/tools/fastix/bin/fastix ${PREFIX}/bin/tools
    cp $SRC_DIR/tools/vg ${PREFIX}/bin/tools
fi
