cd $SRC_DIR/MADroot
make
# tree
mkdir -p $PREFIX/bin
cp madRoot $PREFIX/bin
cp smallExample.txt $PREFIX
