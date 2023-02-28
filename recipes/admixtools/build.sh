# clear out pre-built objects and executables
cd src
make CC=${CC} clobber

make CC=${CC} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" all

make install TOP=$PREFIX/bin
