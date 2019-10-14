mkdir -p ${PREFIX}/bin
make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS -lz -lm"
cp SeqPrep ${PREFIX}/bin
