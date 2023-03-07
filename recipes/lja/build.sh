export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

set -e

echo "Building LJA..."

cd $SRC_DIR

echo "cmake -B$BUILD_PREFIX -S$SRC_DIR"
cmake -B $BUILD_PREFIX -S $SRC_DIR


cd $BUILD_PREFIX
echo "make BUILD_BINDIR=$BUILD_PREFIX BUILD_LIBDIR=$BUILD_PREFIX  $BUILD_PREFIX"

find ./ -type f -exec touch {} +
make clean
make .

echo 'dir .'
ls .
echo 'dir src'
ls $SRC_DIR
echo 'dir prefix'
ls $PREFIX
echo 'dir build'
ls $BUILD_PREFIX

mkdir $PREFIX/bin/
chmod +x ./bin/* 
ln -s $BUILD_DIR/bin/* $PREFIX/bin/

cd $PREFIX/bin