export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/cairo/"
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/cairo/"
export CPATH="${PREFIX}/include:${PREFIX}/include/cairo/"
export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/cairo/"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"

sed -i.bak 's|=/usr/local|=${PREFIX}|g' Makefile
sed -i.bak 's/CC=gcc//g' Makefile
if [ `uname -m` == "aarch64" ]; then
    sed -i.bak 's/  CFLAGS += -m64/  CFLAGS += -mabi=lp64/g' Makefile
fi
make install
make test
