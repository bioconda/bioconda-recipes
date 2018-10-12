cd clipper
CFLAGS="-I. -I${PREFIX}/include -L${PREFIX}/lib" PREFIX=${PREFIX} make install
