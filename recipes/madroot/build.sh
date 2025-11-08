cd $SRC_DIR/MADroot
make
mkdir -p $PREFIX/bin
cp madRoot $PREFIX/bin
cp smallExample.txt $PREFIX
