rm -rf build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" ..
make -j4
make install
cd ..
mkdir -p ${PREFIX}/etc/reseq
cp -r test ${PREFIX}/etc/reseq
cp -r adapters ${PREFIX}/etc/reseq
