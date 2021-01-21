#!/bin/bash
set +ex

# Temporary solution for 0.20.2
# In the future, the halper script should be in the source tarball
wget https://raw.githubusercontent.com/sfiligoi/unifrac/v0.20.2-docs/scripts/install_hpc_sdk.sh
chmod a+x install_hpc_sdk.sh
./install_hpc_sdk.sh
source setup_nv_h5.sh

export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

ls -l
SED='sed -i'

$SED 's/^STATIC_AVAILABLE=.*/STATIC_AVAILABLE="no"/' `which h5c++`
grep STATIC_AVAILABLE `which h5c++`

pushd sucpp
make api
popd

$PYTHON -m pip install --no-deps --ignore-installed .
