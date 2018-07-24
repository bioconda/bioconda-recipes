export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak 's|^./configure$|./configure --prefix="$PREFIX"|g' bootstrap

./bootstrap
make
make unit_tests
./unit_tests
make install
