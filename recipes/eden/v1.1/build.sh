export CXXFLAGS="-I$PREFIX/include"
export LIBS="-L$PREFIX/lib"
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
