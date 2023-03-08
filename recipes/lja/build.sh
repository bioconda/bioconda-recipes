set -e

echo "Building LJA..."

cd $SRC_DIR

echo "cmake -S $SRC_DIR"
cmake -S $SRC_DIR

echo "make"
make CXX=$CXX INCLUDES="-I$PREFIX/include" CFLAGS+="-L$PREFIX/lib"

mv $SRC_DIR/* $PREFIX

echo 'dir src'
ls $SRC_DIR
echo 'dir prefix'
ls $PREFIX
echo 'dir build'
ls $BUILD_PREFIX

cd $PREFIX/bin