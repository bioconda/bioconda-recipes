export CFLAGS="${CFLAGS} -std=c89"
./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}"
make
make check
make install
