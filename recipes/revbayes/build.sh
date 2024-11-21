#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p $PREFIX/bin
cd projects/cmake

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# MPI version
./regenerate.sh -mpi true

./build.sh -mpi true -help2yml true \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_PREFIX_PATH="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-boost_root "${PREFIX}" \
	-j "${CPU_COUNT}" \
	"${CONFIG_ARGS}"

chmod 0755 rb-mpi rb-mpi-help2yml
mv rb-mpi rb-mpi-help2yml $PREFIX/bin/


# Non-mpi version
rm -rf build-mpi

./regenerate.sh

./build.sh -mpi false -help2yml true \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -boost_root "${PREFIX}" \
        -j "${CPU_COUNT}" \
        "${CONFIG_ARGS}"

chmod 0755 rb rb-help2yml
mv rb rb-help2yml $PREFIX/bin/

rm -rf build
