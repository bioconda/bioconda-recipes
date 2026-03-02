make CFLAGS="-c -Wall -g -I${PREFIX}/include -I lib" LFLAGS="-L${PREFIX}/lib -g -o"
mkdir -p $PREFIX/bin
cp bin/eggs $PREFIX/bin
