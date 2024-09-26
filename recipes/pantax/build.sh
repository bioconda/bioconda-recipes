#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd gurobi11
    ${PYTHON} -m pip install gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    rm gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    cd $SRC_DIR
    chmod +x pantax
    cp $SRC_DIR/scripts/pantax ${PREFIX}/bin
    cp $SRC_DIR/scripts/*py ${PREFIX}/bin
    mkdir -p ${PREFIX}/bin/tools
    cd vg
    cp vg* ${PREFIX}/bin/tools/vg
    cd $SRC_DIR/tools/fastix
    cargo install fastix --root ./
    cp $SRC_DIR/tools/fastix/bin/fastix ${PREFIX}/bin/tools
fi
