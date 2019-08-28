set -xe
echo "Start build..."

## export these flags so that zlib.h can be found
#export CFLAGS="-I$PREFIX/include"
#export CXXFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

## Build zlib, and then tabix, samtools against zlib
#(cd third && tar zxf zlib-1.2.8.tar.gz && cd zlib-1.2.8 && ./configure && make)
#(cd third && tar jxf tabix-0.2.6.tar.bz2 && ln -s -f tabix-0.2.6 tabix && cd tabix-0.2.6 && sed -i.bak 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8:'  Makefile && make libtabix.a)
#(cd third && tar jxf samtools-0.1.19.tar.bz2 && ln -s -f samtools-0.1.19 samtools && cd samtools-0.1.19 && sed -i.bak 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8 -I../../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8 -L../../zlib-1.2.8:' Makefile bcftools/Makefile && make lib-recur)
(sed -i.bak 's:CXX_FLAGS = -O2 -DNDEBUG:CXX_FLAGS = -O2 -DNDEBUG -I../third/zlib-1.2.8:' libsrc/Makefile)
(sed -i.bak 's:cd tabix-0.2.6; make:cd tabix-0.2.6; make libtabix.a:' third/Makefile)

(cd third && tar zxf zlib-1.2.8.tar.gz && cd zlib-1.2.8 && ./configure && make)
(sed -i.bak 's/cnpy: cnpy.zip/cnpy: cnpy.zip zlib/' third/Makefile)
(sed -i.bak 's:-c cnpy.cpp:-c cnpy.cpp -I../zlib:' third/Makefile)
(cd third && make cnpy && sed -i.bak 's:#include<zlib.h>:#include "../zlib/zlib.h":' cnpy/cnpy.h)
cat third/Makefile

# Use system zlib
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
(sed -i.bak 's:^CXX_INCLUDE =:CXX_INCLUDE = -I${PREFIX}/include:' Makefile.common)
(sed -i.bak 's:^CXX_LIB =:CXX_LIB = -L${PREFIX}/lib:' Makefile.common)

if [[ $(uname -s) == Darwin ]]; then
  sed -i.bak 's/release: CXX_FLAGS =/ release: CXX_FLAGS = -headerpad_max_install_names /' vcfUtils/Makefile
  make STATIC_FLAG='-fopenmp'
else
  # hack this flag to link against rt, so clock_gettime can be linked
  make STATIC_FLAG='-lrt'
fi

# Install
echo "Install..."
mkdir -p $PREFIX/bin
echo "Copying..."
if [[ $(uname -s) == Darwin ]]; then
  # Mac does not have `-executable` option
  find executable/ -perm +111 -type f -exec cp {} $PREFIX/bin \;
else
  find executable/ -executable -type f -exec cp {} $PREFIX/bin \;
fi
