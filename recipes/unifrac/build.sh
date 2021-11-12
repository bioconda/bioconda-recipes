#!/bin/bash
set +ex
export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

ls -l
if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.12
    SED="sed -i ''"
else
    SED='sed -i'
fi

$SED 's/^STATIC_AVAILABLE=.*/STATIC_AVAILABLE="no"/' `which h5c++`
grep STATIC_AVAILABLE `which h5c++`

pushd sucpp
make api
popd

$PYTHON -m pip install --no-deps --ignore-installed .
