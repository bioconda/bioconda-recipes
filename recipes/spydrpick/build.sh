#!/bin/bash

# Set up Apegrunt; it's configured as a submodule to SpydrPick on GitHub, but since
# Bioconda doesn't recommend using git_url (and 'clone --recursive' that would also
# clone the submodule), we do it manually instead
rmdir externals/apegrunt
git clone --branch v0.4.2 https://github.com/santeripuranen/apegrunt.git externals/apegrunt

# build and install SpydrPick (but only the SpydrPick make target)
export CMAKE_MODULE_PATH=${RECIPE_DIR}
mkdir build && pushd build
cmake -DTBB_ROOT=${PREFIX} -DBOOST_ROOT=${PREFIX} -DBoost_DEBUG=1 ..
make VERBOSE=1 SpydrPick
install -d ${PREFIX}/bin
install bin/SpydrPick ${PREFIX}/bin
popd
