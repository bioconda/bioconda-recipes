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
echo '$BUILD_PREFIX/includes'
ls $BUILD_PREFIX/includes

echo "make"
make CXX=$CXX INCLUDES="-I$PREFIX/include" CFLAGS+="-L$PREFIX/lib"

mv $SRC_DIR/* $PREFIX

cd $PREFIX/bin