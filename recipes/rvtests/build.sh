## export these flags so that zlib.h can be found
#export CFLAGS="-I$PREFIX/include"
#export CXXFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

# Build
(cd third && tar zvxf zlib-1.2.8.tar.gz && cd zlib-1.2.8 && ./configure && make)
(cd third && tar jvxf tabix-0.2.6.tar.bz2 && cd tabix-0.2.6 && sed -i 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8:'  Makefile && make libtabix.a)
(cd third && tar jvxf samtools-0.1.19.tar.bz2 && cd samtools-0.1.19 && sed -i 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8:' Makefile && sed -i 's:^CFLAGS=:CFLAGS=-I../../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../../zlib-1.2.8:' bcftools/Makefile && make)

make

# Install
mkdir -p $PREFIX/bin
find executable -executable -exec cp {} $PREFIX/bin \;
