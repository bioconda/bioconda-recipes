cd bin
make CC=${CC} FC=${FC}
# All the executable perl scripts have the interpreter hardcoded
sed -i 's/bin\/perl/bin\/env perl/g' *.pl
cp * $PREFIX/bin
