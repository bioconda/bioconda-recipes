
set -e
set -x

# sed -i '20i link_directories("lib" "${SRC_DIR}/lib" "${PREFIX}/lib" "${SYS_PREFIX}/lib")' CMakeLists.txt
# sed -i '20i include_directories("include" "${SRC_DIR}/include" "${PREFIX}/include" "${PREFIX}/include/shrinkwrap" "${PREFIX}/include/htslib" "${SYS_PREFIX}/include")' CMakeLists.txt

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CXX3_ABI=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" \
  ${SRC_DIR}

make -j${CPU_COUNT} savvy
make -j${CPU_COUNT} sav
make install
