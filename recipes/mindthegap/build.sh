#!/bin/bash


sed -i.bak 's/cmake_minimum_required(VERSION 3.1)/cmake_minimum_required(VERSION 3.5...3.28)/g' CMakeLists.txt
export CFLAGS="${CFLAGS} -DH5_USE_110_API=1"
export CXXFLAGS="${CXXFLAGS} -D_HDF5USEDLL_=1"

sed -i '1i #include "H5public.h"\n#if defined(H5_HAVE_114_API) || H5_VERSION_GE(1,12,0)\n#include "H5CXpublic.h"\n#else\n#define H5CX_set_apl(...) (0)\n#endif\n' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Odeprec.c


sed -i 's/H5P__encode_chunk_cache_nslots(const void \*value, void \*\*_pp, size_t \*size)/H5P__encode_chunk_cache_nslots(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
sed -i '117s/)/, void *udata)/' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
sed -i 's/H5P__encode_chunk_cache_nbytes(const void \*value, void \*\*_pp, size_t \*size)/H5P__encode_chunk_cache_nbytes(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
sed -i '120s/)/, void *udata)/' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
sed -i 's/H5P__dapl_vds_file_pref_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__dapl_vds_file_pref_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pdapl.c
sed -i 's/H5P__facc_libver_type_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__facc_libver_type_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pfapl.c
sed -i 's/H5P__ocpy_merge_comm_dt_list_enc(const void \*value, void \*\*_pp, size_t \*size)/H5P__ocpy_merge_comm_dt_list_enc(const void \*value, void \*\*_pp, size_t \*size, void \*udata)/g' thirdparty/gatb-core/gatb-core/thirdparty/hdf5/src/H5Pocpypl.c
sed -i 's/this->m_solid_stretch_size()/this->m_solid_stretch_size/g' src/FindBreakpoints.hpp



export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" ..
make -j2

mkdir -p $PREFIX/bin/

cp bin/MindTheGap ${PREFIX}/bin/
chmod +x $PREFIX/bin/MindTheGap

cp ext/gatb-core/bin/dbgh5 ${PREFIX}/bin/
chmod +x $PREFIX/bin/dbgh5
cp ext/gatb-core/bin/dbginfo ${PREFIX}/bin/
chmod +x $PREFIX/bin/dbginfo
