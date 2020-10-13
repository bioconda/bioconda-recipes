mkdir -p $PREFIX/bin $PREFIX/data
cp bin/dligand2.gnu $PREFIX/bin/dligand2
cp bin/*2 $PREFIX/data
export DATADIR=$PREFIX/data
