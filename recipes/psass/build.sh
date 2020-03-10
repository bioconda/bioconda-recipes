mkdir -p $PREFIX/bin/
make CXX=$CXX CC=$CC
cp bin/* $PREFIX/bin/
