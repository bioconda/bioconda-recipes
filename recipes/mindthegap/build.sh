#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -DH5_USE_110_API=1"
export CXXFLAGS="${CXXFLAGS} -O3 -D_HDF5USEDLL_=1 -DUSE_NEW_CXX"

mkdir -p $PREFIX/bin

sed -i.bak 's/cmake_minimum_required(VERSION 3.1)/cmake_minimum_required(VERSION 3.5...3.28)/g' CMakeLists.txt
rm -f *.bak

if [[ `uname -s` == "Linux" ]]; then
  sed -i '1i #include "H5public.h"\n#if defined(H5_HAVE_114_API) || H5_VERSION_GE(1,12,0)\n#include "H5CXpublic.h"\n#else\n#define H5CX_set_apl(...) (0)\n#endif\n' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Odeprec.c

  sed -i 's/H5P__encode_chunk_cache_nslots(const void \*value, void \*\*_pp, size_t \*size)/H5P__encode_chunk_cache_nslots(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
  sed -i '117s/)/, void *udata)/' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
  sed -i 's/H5P__encode_chunk_cache_nbytes(const void \*value, void \*\*_pp, size_t \*size)/H5P__encode_chunk_cache_nbytes(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
  sed -i '120s/)/, void *udata)/' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
  sed -i 's/H5P__dapl_vds_file_pref_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__dapl_vds_file_pref_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
  sed -i 's/H5P__facc_libver_type_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__facc_libver_type_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pfapl.c
  sed -i 's/H5P__ocpy_merge_comm_dt_list_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__ocpy_merge_comm_dt_list_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pocpypl.c
  sed -i 's/this->m_solid_stretch_size()/this->m_solid_stretch_size/g' src/FindBreakpoints.hpp
fi

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

install -v -m build/bin/MindTheGap build/ext/gatb-core/bin/dbgh5 build/ext/gatb-core/bin/dbginfo "${PREFIX}/bin"
