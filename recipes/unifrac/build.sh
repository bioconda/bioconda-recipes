#!/bin/bash

export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.12
fi

pushd sucpp
make api
popd

$PYTHON -m pip install --no-deps --ignore-installed .
