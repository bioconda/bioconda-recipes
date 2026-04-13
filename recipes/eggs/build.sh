make CC=${CC} CFLAGS="${CFLAGS} -I${PREFIX}/include -I lib" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
cp bin/eggs $PREFIX/bin
