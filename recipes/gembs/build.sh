#!/bin/bash
set -ex
pushd tools
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
if [[ ${target_platform} =~ linux.* ]] ; then
    # Workaround for glibc<2.17 where clock_gettime is in librt. (clock_time being used by bs_call.)
    make MAKE_BUILD_TYPE=Release MAKE_INSTALL_PREFIX="${PREFIX}" MAKE_EXE_LINKER_FLAGS_INIT=-lrt ..
else
    make MAKE_BUILD_TYPE=Release MAKE_INSTALL_PREFIX="${PREFIX}" ..
fi
make CC="${CC}"
popd
#pushd tools
#make setup _utils CC=${CC} LDFLAGS="${LDFLAGS}"
#popd

python -m pip install . -vv --no-deps --install-option="--minimal"
