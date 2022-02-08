#!/bin/bash
set -ex
pushd tools
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
if [[ "${target_platform}" =~ linux* ]]; then
    # Workaround for glibc<2.17 where clock_gettime is in librt. (clock_time being used by bs_call.)
    sed -i 's/BS_CALL_LIBS:= \$(LIBS) -lpthread/BS_CALL_LIBS:= \$(LIBS) -lpthread -lrt/' bs_call/src/Makefile
else
    echo Nothing to see here move along
fi
make CC="${CC}" LDFLAGS="${LDFLAGS}"
popd
#pushd tools
#make setup _utils CC=${CC} LDFLAGS="${LDFLAGS}"
#popd
python3 setup.py install --single-version-externally-managed --record=record.txt
