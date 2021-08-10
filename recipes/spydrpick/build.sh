#!/bin/bash

# build and install SpydrPick (build only the 'SpydrPick' make target)
export CMAKE_MODULE_PATH=${RECIPE_DIR}
mkdir build && pushd build
cmake -DTBB_ROOT=${PREFIX} -DBOOST_ROOT=${PREFIX} -DBoost_DEBUG=1 -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make VERBOSE=1 SpydrPick
install -d ${PREFIX}/bin
install bin/SpydrPick ${PREFIX}/bin
popd
