#!/bin/bash
# build unitig-counter
if [[ ${target_platform}  == "linux-aarch64" ]]; then
	sed -i "60c #set(Boost_USE_STATIC_LIBS   ON)" CMakeLists.txt
	sed -i "67c \\\    set (CMAKE_C_FLAGS \"${CMAKE_C_FLAGS} -Wundef -Wshadow -Wpointer-arith -Wbad-function-cast -Wcast-qual -Wcast-align -Wwrite-strings -Wconversion -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wnested-externs -Winline -Wno-int-conversion -Wno-implicit-function-declaration\")" gatb-core/gatb-core/thirdparty/hdf5/config/cmake/HDFCompilerFlags.cmake 
fi
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DBoost_INCLUDE_DIR=${PREFIX}/include -DBoost_LIBRARY_DIR=${PREFIX}/lib -DCMAKE_INSTALL_PREFIX=$PREFIX  -DCMAKE_POLICY_VERSION_MINIMUM=3.5  -DCMAKE_C_FLAGS="-I$CONDA_PREFIX/include $CMAKE_C_FLAGS" ..
make VERBOSE=1
install -d $PREFIX/bin
install unitig-counter cdbg-ops ext/gatb-core/bin/Release/gatb-h5dump $PREFIX/bin
popd
