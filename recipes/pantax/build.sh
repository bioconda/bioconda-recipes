#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cd $SRC_DIR/PanTax
    cp $SRC_DIR/PanTax/* $PREFIX
else
    cd gurobi11
    python -m pip install gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    rm gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    cd $SRC_DIR/pantax
    chmod +x pantax
    cp $SRC_DIR/pantax/pantax ${PREFIX}/bin
    cp $SRC_DIR/pantax/pantax ${PREFIX}
    cp $SRC_DIR/pantax/*sh ${PREFIX}/bin
    cp $SRC_DIR/pantax/*py ${PREFIX}/bin
    cd $SRC_DIR/tools
    chmod +x vg
    cd $SRC_DIR
    cargo install fastix --root ./
    mkdir -p ${PREFIX}/bin/tools
    cp $SRC_DIR/bin/fastix ${PREFIX}/bin/tools
    cp $SRC_DIR/tools/vg ${PREFIX}/bin/tools
fi
