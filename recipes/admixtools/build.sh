# clear out pre-built objects and executables
cd src
make clobber

make CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" all

make install TOP=$PREFIX/bin
