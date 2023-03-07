export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

set -e

echo "Building LJA..."

cd $SRC_DIR

echo "cmake -B$BUILD_PREFIX -S$SRC_DIR"
cmake -S $SRC_DIR

echo "make BUILD_BINDIR=$BUILD_PREFIX BUILD_LIBDIR=$BUILD_PREFIX  $BUILD_PREFIX"

make

echo 'dir .'
ls .
echo 'dir src'
ls $SRC_DIR
echo 'dir prefix'
ls $PREFIX
echo 'dir build'
ls $BUILD_PREFIX

mv $SRC_DIR/* $PREFIX

cd $PREFIX/bin