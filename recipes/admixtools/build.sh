# clear out pre-built objects and executables
cd src
make clobber

make CFLAGS="-Wno-unused-comparison -Wno-return-type -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" all

make install TOP=$PREFIX/bin
