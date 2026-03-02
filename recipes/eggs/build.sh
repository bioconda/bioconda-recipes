make CFLAGS="-c -Wall -g -I${PREFIX}/include" LFLAGS="-L${PREFIX}/lib -g -o"
mkdir -p $PREFIX/bin
cp bin/eggs $PREFIX/bin
