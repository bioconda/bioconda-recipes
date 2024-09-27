#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd ${SRC_DIR}/gurobi11
    ${PYTHON} -m pip install gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    rm gurobipy-11.0.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
    
    mkdir -p ${PREFIX}/bin/tools
    cd ${SRC_DIR}/vg
    cp vg* ${PREFIX}/bin/tools/vg
    chmod +x ${PREFIX}/bin/tools/vg
    
    cd ${SRC_DIR}/scripts
    chmod +x pantax
    chmod +x data_preprocessing
    cp ${SRC_DIR}/scripts/pantax ${SRC_DIR}/scripts/data_preprocessing ${PREFIX}/bin
    cp ${SRC_DIR}/scripts/*py ${PREFIX}/bin
    
    cd ${SRC_DIR}/tools/fastix
    cargo install fastix --root ./
    cp ${SRC_DIR}/tools/fastix/bin/fastix ${PREFIX}/bin/tools
fi
