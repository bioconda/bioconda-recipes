# change directory
cd 1.9

## Portable sha1 sums across linux and os x
#sed -i.bak -e "s/shasum/openssl sha1 -r/g" plink_first_compile
#
## Remove "make plink" so we can call it with overrides
#sed -i.bak -e "s/make -f Makefile.std plink//g" plink_first_compile
#
## This downloads and builds a local zlib
#./plink_first_compile
#
## Build using Makefile.std as recommended in the README
#if [[ -z "$OSX_ARCH" ]]; then
#    make CFLAGS="-Wall -O2 -I$PREFIX/include" BLASFLAGS="-L$PREFIX/lib -lopenblas" -f Makefile.std plink
#else
#    make -f Makefile.std plink
#fi
CFLAGS="$CFLAGS -DDYNAMIC_ZLIB"
CXXFLAGS="$CXXFLAGS -DDYNAMIC_ZLIB"
sed -i.bak "s#gfortran#${FC}#g" Makefile.std
make -f Makefile.std LDFLAGS="$LDFLAGS -lm -lpthread -ldl -lgfortran" ZLIB="-lz" BLASFLAGS="-lopenblas"

# Install as plink
mkdir -p $PREFIX/bin
cp plink $PREFIX/bin/
