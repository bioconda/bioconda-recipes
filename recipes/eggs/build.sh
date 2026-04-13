make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS -I lib"
mkdir -p $PREFIX/bin
cp bin/eggs $PREFIX/bin
