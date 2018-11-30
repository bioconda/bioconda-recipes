## export these flags so that zlib.h can be found
#export CFLAGS="-I$PREFIX/include"
#export CXXFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

if [[ $(uname -s) == Darwin ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew install gcc
fi

# Build
(cd third && tar zxf zlib-1.2.8.tar.gz && cd zlib-1.2.8 && ./configure && make)
(cd third && tar jxf tabix-0.2.6.tar.bz2 && ln -s -f tabix-0.2.6 tabix && cd tabix-0.2.6 && sed -i 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8:'  Makefile && make libtabix.a)
(cd third && tar jxf samtools-0.1.19.tar.bz2 && ln -s -f samtools-0.1.19 samtools && cd samtools-0.1.19 && sed -i 's:^CFLAGS=:CFLAGS=-I../zlib-1.2.8 -I../../zlib-1.2.8:;s:^LIBPATH=:LIBPATH=-L../zlib-1.2.8 -L../../zlib-1.2.8:' Makefile bcftools/Makefile && make lib-recur)
(sed -i 's:CXX_FLAGS = -O2 -DNDEBUG:CXX_FLAGS = -O2 -DNDEBUG -I../third/zlib-1.2.8:' libsrc/Makefile)

#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
(sed -i 's:^CXX_INCLUDE =:CXX_INCLUDE = -I${PREFIX}/include:' Makefile.common)
(sed -i 's:^CXX_LIB =:CXX_LIB = -L${PREFIX}/lib:' Makefile.common)

if [[ $(uname -s) == Darwin ]]; then
  make STATIC_FLAG='' OPENMP_FLAG='' CXX=clang++ CC=clang
else
  # hack this flag to link against rt, so clock_gettime can be linked
  make STATIC_FLAG='-lrt'
fi

# Install
echo "Install..."
mkdir -p $PREFIX/bin
echo "Copying..."
find executable/ -executable -type f -exec cp {} $PREFIX/bin \;
