# build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${CPU_COUNT}

# install
mkdir -p ${PREFIX}/bin
make install
