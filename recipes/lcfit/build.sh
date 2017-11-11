export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
make test

cp lcfit_src/*.h ${PREFIX}/include
cp lcfit_cpp_src/*.h ${PREFIX}/include
cp _build/release/lcfit_src/liblcfit.so ${PREFIX}/lib
cp _build/release/lcfit_cpp_src/liblcfit_cpp.so ${PREFIX}/lib
cp _build/release/lcfit_cpp_src/liblcfit_cpp-static.a ${PREFIX}/lib
