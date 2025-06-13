cd src
make CC="${CC}" CFLAGS="${CFLAGS} -std=gnu89 -Wno-old-style-definition"
make install bindir="${PREFIX}/bin/"
