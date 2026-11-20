

export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

chmod +x ./configure
./configure --prefix=$PREFIX
make
make install
