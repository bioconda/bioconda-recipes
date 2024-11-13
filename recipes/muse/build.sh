#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

# Print environment variables for debugging
echo "Print env variables"
echo "LIBPATH: ${LIBPATH}"
echo "LDFLAGS: ${LDFLAGS}"
echo "CFLAGS: ${CFLAGS}"

rm -rf boost_1_70_0/

ln -sf ${CC} ${BUILD_PREFIX}/bin/gcc
ln -sf ${CXX} ${BUILD_PREFIX}/bin/c++
ln -sf ${GXX} ${BUILD_PREFIX}/bin/g++

./install_muse.sh

# List the contents of the PREFIX directory to see where files are placed
echo "Listing contents of ${PREFIX}:"
ls -R "${PREFIX}"

chmod 0755 MuSE
cp -f MuSE "${PREFIX}/bin"
