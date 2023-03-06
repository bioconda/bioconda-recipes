export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

set -e

echo "Building LJA..."

cmake -B$BUILD_PREFIX -S$SRC_DIR

make BUILD_BINDIR=$BUILD_PREFIX BUILD_LIBDIR=$BUILD_PREFIX

ln -s $SRC_DIR/bin/* $PREFIX/bin/

cd $PREFIX/bin

chmod +x ./*