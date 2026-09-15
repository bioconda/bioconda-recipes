#!/bin/bash

install -d "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
    export CFLAGS="${CFLAGS} -Wno-error=int-conversion -Wno-error=incompatible-pointer-types"
    export CXXFLAGS="${CXXFLAGS} -Wno-error=int-conversion -Wno-error=incompatible-pointer-types"
	export HDF5_DISABLE_VERSION_CHECK=1
    export HDF5_SKIP_MPI_TEST=1
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DHDF5_BUILD_CPP_LIB=OFF -DHDF5_ENABLE_PARALLEL=OFF"
	sed -i.bak 's|set(MPI_TEST_EXECUTABLE ${MPIEXEC_EXECUTABLE})|set(MPI_TEST_EXECUTABLE ${MPIEXEC_EXECUTABLE} CACHE INTERNAL "")|' gatb-core/gatb-core/thirdparty/hdf5/config/cmake_ext_mod/HDFMacros.cmake
    sed -i.bak 's|set_target_properties (${libtarget} PROPERTIES OUTPUT_NAME ${libname})|set_target_properties (${libtarget} PROPERTIES OUTPUT_NAME ${libname} MACOSX_RPATH ON)|' gatb-core/gatb-core/thirdparty/hdf5/config/cmake/HDFMacros.cmake
else
    export CONFIG_ARGS="-DHDF5_BUILD_CPP_LIB=OFF -DHDF5_ENABLE_PARALLEL=OFF"
fi

sed -i.bak 's|Boost_USE_STATIC_LIBS   ON|Boost_USE_STATIC_LIBS   OFF|' CMakeLists.txt
sed -i.bak 's|-Wnested-externs -Winline|-Wnested-externs -Winline -Wno-int-conversion -Wno-implicit-function-declaration|' gatb-core/gatb-core/thirdparty/hdf5/config/cmake/HDFCompilerFlags.cmake
rm -rf *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DBOOST_ROOT="${PREFIX}" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
    -DHDF5_ENABLE_Z_LIB_SUPPORT=ON \
    -DHDF5_ENABLE_SZIP_SUPPORT=OFF \
    -DHDF5_ENABLE_SZIP_ENCODING=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build -j 1

cd build
install -v -m 0755 unitig-counter cdbg-ops ext/gatb-core/bin/Release/gatb-h5dump "$PREFIX/bin"
