#!/bin/bash
set -euxo pipefail

# Arrange ncbi-vdb files in a form that NCBI C++ tookit
# build can consume them.
VDB=$SRC_DIR/vdb
mkdir "$VDB"
if [[ $(uname) = Linux ]] ; then
   VDB_LIB="$VDB/linux/release/x86_64/lib"
else
   VDB_LIB="$VDB/mac/release/x86_64/lib"
fi
mkdir -p "$VDB_LIB"
cp -R "$PREFIX"/lib/libncbi-* "$VDB_LIB/"
mkdir "$VDB/interfaces"
# ncbi-vdb 3.4 installs its interfaces directly under include/.
if [[ -d "$PREFIX/include/ncbi-vdb" ]]; then
    VDB_INCLUDE="$PREFIX/include/ncbi-vdb"
else
    VDB_INCLUDE="$PREFIX/include"
fi
for interface in align cc cloud csra csra2 ext insdc kapp kdb kfc kfg kfs klib kns kproc krypto ktst ncbi ngs os sra vdb vfs; do
    if [[ -d "$VDB_INCLUDE/$interface" ]]; then
        cp -R "$VDB_INCLUDE/$interface" "$VDB/interfaces/"
    fi
done


# Build Magic-BLAST
cd $SRC_DIR/c++/

export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CC_FOR_BUILD=$CC

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib -lz -lbz2"
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
    export CPP_FOR_BUILD=$CPP
fi

LIB_INSTALL_DIR=$PREFIX/lib/ncbi-magicblast

# with/without options:
#
# dll: enable dynamic linking
# mt: enable multi-threading
# -autodep: no automatic dependency build (one time build)
# -makefile-auto-update: no rebuild of makefile (one time build)
# flat-makefile: use single makefile
# -caution: disable configure script warnings
# -dbapi: don't build database connectivity libs
# -lzo: don't add lzo support
# runpath: set runpath for installed $PREFIX location
# hard-runpath: disable new dtags (disallow LD_LIBRARY_PATH override on Linux)
# -debug: disable debug
# strip: remove debugging symbols (size!)
# -vdb: disable VDB/SRA toolkit
# z: set zlib
# bz2: set libbz2
# -openssl: disable openssl
# -gcrypt: disable gcrypt (needed on OSX)
# -krb5: disable kerberos (needed on OSX)

# Fixes building on Linux
export AR="${AR} rcs" 

if [[ $(uname) = Linux ]] ; then
    ./configure \
        --with-bin-release \
        --with-mt \
        --with-openmp \
        --with-flat-makefile \
        --without-debug \
        --with-strip \
        --with-vdb=$VDB \
        --with-static-vdb \
        --with-z=$PREFIX \
        --with-bz2=$PREFIX \
        --without-gnutls \
        --without-gcrypt \
        --without-pcre
else
    ./configure \
        --with-bin-release \
        --with-mt \
        --without-openmp \
        --with-flat-makefile \
        --without-debug \
        --with-strip \
        --with-vdb=$VDB \
        --with-static-vdb \
        --with-z=$PREFIX \
        --with-bz2=$PREFIX \
        --without-gnutls \
        --without-gcrypt \
        --without-pcre
fi

cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s $SRC_DIR/c++/ReleaseMT/lib $LIB_INSTALL_DIR

cd build
make -j${CPU_COUNT} -f Makefile.flat magicblast.exe

# remove temporary link
rm $LIB_INSTALL_DIR

mkdir -p $PREFIX/bin $LIB_INSTALL_DIR
cp $SRC_DIR/c++/ReleaseMT/bin/magicblast $PREFIX/bin/

chmod +x $PREFIX/bin/magicblast

