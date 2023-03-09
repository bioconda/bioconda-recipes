set -e

echo "Building LJA..."

cd $SRC_DIR

echo "cmake -S $SRC_DIR"
cmake -S $SRC_DIR

echo 'dir src'
ls $SRC_DIR
echo 'dir prefix'
ls $PREFIX
echo 'dir prefix/include'
ls $PREFIX/lib
echo 'dir prefix/lib'
ls $PREFIX/lib
echo 'dir build'
ls $BUILD_PREFIX
echo '$BUILD_PREFIX/lib'
ls $BUILD_PREFIX/lib
echo '$BUILD_PREFIX/include'
ls $BUILD_PREFIX/include

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -lrt -L$PREFIX/lib"
export CPATH=${PREFIX}/include

echo "make"
# fix of gettime bug
sed -i 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS} -lrt" )/g' $SRC_DIR/CMakeLists.txt
make

mv $SRC_DIR/* $PREFIX

cd $PREFIX/bin