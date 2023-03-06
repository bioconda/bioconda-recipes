export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

set -e

echo "Building LJA..."

cmake .

make

cp -r $SRC_DIR/bin/* $PREFIX/bin/

cd $PREFIX/bin

chmod +x ./*