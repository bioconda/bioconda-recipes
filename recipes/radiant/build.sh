
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -S . -B build
cmake --build build
cmake --install build

