set -e

echo "Building LJA..."

cd $SRC_DIR

echo "cmake -S $SRC_DIR"
cmake -S $SRC_DIR

echo "make"
# fix of gettime bug
sed -i 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS} -lrt" )/g' $SRC_DIR/CMakeLists.txt
make CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"

cp -r $SRC_DIR/bin $PREFIX
cp -r $SRC_DIR/src $PREFIX
