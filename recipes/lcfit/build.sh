export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CMAKE_FLAGS="-D CMAKE_C_COMPILER=${CC} -D CMAKE_CXX_COMPILER=${CXX} -D GSL_INCLUDES=${PREFIX}/include"
make test CMAKE_FLAGS="-D CMAKE_C_COMPILER=${CC} -D CMAKE_CXX_COMPILER=${CXX} -D GSL_INCLUDES=${PREFIX}/include"

cp lcfit_src/*.h ${PREFIX}/include
cp lcfit_cpp_src/*.h ${PREFIX}/include
cp _build/release/lcfit_src/liblcfit.so ${PREFIX}/lib
cp _build/release/lcfit_cpp_src/liblcfit_cpp.so ${PREFIX}/lib
cp _build/release/lcfit_cpp_src/liblcfit_cpp-static.a ${PREFIX}/lib
