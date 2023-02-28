mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DSTATIC=OFF ..
make install
