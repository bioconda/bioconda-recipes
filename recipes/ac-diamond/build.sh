mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -msse4.1" \
    -DCMAKE_CXX_STANDARD=98 \
    ..
make
make install
