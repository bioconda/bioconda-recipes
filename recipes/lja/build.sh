set -e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

echo "Building LJA..."

cmake .

make

cp -r $SRC_DIR/bin/* $PREFIX/bin/

cd $PREFIX/bin

chmod +x ./*