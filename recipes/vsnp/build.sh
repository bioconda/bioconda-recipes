echo "PREFIX: $PREFIX"
ls
echo "-----"

mkdir -p ${PREFIX}/bin
cp *py ${PREFIX}/bin

mkdir -p $PREFIX/dependencies
cp dependencies/* $PREFIX/dependencies
