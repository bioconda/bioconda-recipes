cd bin
# Replace the hardcoded gcc and gfortran with ones specified via environment variables
sed -i 's/gcc/${CC}/g' Makefile
sed -i 's/gfortran/${FC}/g' Makefile
make
cp * $PREFIX/bin
