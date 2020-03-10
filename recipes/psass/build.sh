echo $(gcc --help)
echo $(which gcc)
echo $(gcc --version)

mkdir -p $PREFIX/bin/
make
cp bin/* $PREFIX/bin/
