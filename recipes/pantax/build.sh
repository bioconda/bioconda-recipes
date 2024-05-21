#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cd $SRC_DIR
    cp $SRC_DIR/* $PREFIX
else
    chmod +x pantax
    cd $SRC_DIR/tools
    chmod +x vg
    cd fastix
    cargo install fastix --root ./
fi