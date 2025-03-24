cd bin
make CC=${CC} FC=${FC}
# All the executable perl scripts have the interpreter hardcoded
sed -i '1d' *.pl
cp * $PREFIX/bin
