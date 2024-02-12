#!/bin/bash
set -euxo pipefail

export BLAST_SRC_DIR="${SRC_DIR}/blast"
cd $BLAST_SRC_DIR/c++/

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

LIB_INSTALL_DIR=$PREFIX/lib/ncbi-blast+

# Get optional RpsbProc
# The rpsbproc command line utility is an addition to the standalone version of
# Reverse Position-Specific BLAST (RPS-BLAST), also known as CD-Search (Conserved
# Domain Search).
mkdir -p src/app/RpsbProc
cp -rf "${SRC_DIR}/RpsbProc/src/"* src/app/RpsbProc/

# Configuration synopsis:
# https://ncbi.github.io/cxx-toolkit/pages/ch_config.html#ch_config.ch_configget_synopsi
#
# Description of used options (from ./configure --help):
# bin-release:
#   Build executables suitable for public release
# 64:
#   Compile in 64-bit mode instead of 32-bit.
# mt:
#   Compile in a multi-threading safe manner.
# dll:
#   Use dynamic instead of static linking.
# openmp:
#   Enable OpenMP extensions for all projects.
# autodep:
#   No automatic dependency build (one time build).
# makefile-auto-update:
#   No rebuild of makefile (one time build).
# flat-makefile:
#   Use single makefile.
# caution:
#   Proceed configuration without asking when in doubt.
# lzo:
#   Don't add lzo support (compression lib, req. lzo >2.x).
# runpath:
#   Set runpath for installed $PREFIX location.
# hard-runpath:
#   Hard-code runtime path, ignoring LD_LIBRARY_PATH (disallow LD_LIBRARY_PATH override on Linux).
# debug:
#   Strip -D_DEBUG and -g, engage -DNDEBUG and -O.
# with-experimental=Int8GI:
#   Enable named experimental feature: Int8GI (Use a simple 64-bit type for GI numbers).
#   See c++/src/build-system/configure.ac lines 1020:1068 for the named options.
# strip:
#   Strip binaries at build time (remove debugging symbols)
# vdb:
#   Disable VDB/SRA toolkit.
# z:
#   Set zlib path (compression lib).
# bz2:
#   Set bzlib path (compression lib).
# krb5:
#   Disable kerberos (needed on OSX).
# gnutls:
#   Disable gnutls.
# gcrypt:
#   Disable gcrypt (needed on OSX).
# sse42
#   Don't enable SSE 4.2 when optimizing.
# pcre:
#   Disable pcre (Perl regex).

# Fixes building on unix (linux and osx)
export AR="${AR} rcs"

if [[ $(uname) = Linux ]] ; then
    ./configure \
        --with-bin-release \
        --with-64 \
        --with-mt \
        --with-dll \
        --with-openmp \
        --without-autodep \
        --without-makefile-auto-update \
        --with-flat-makefile \
        --without-caution \
        --without-lzo \
        --with-hard-runpath \
        --with-runpath=$LIB_INSTALL_DIR \
        --without-debug \
        --with-experimental=Int8GI \
        --with-strip \
        --with-vdb=$PREFIX \
        --with-z=$PREFIX \
        --with-bz2=$PREFIX \
        --without-krb5 \
        --without-gnutls \
        --without-sse42
else
    ./configure \
        --with-bin-release \
        --with-mt \
        --without-openmp \
        --with-flat-makefile \
        --without-lzo \
        --without-zstd \
        --without-debug \
        --with-experimental=Int8GI \
        --with-strip \
        --with-vdb=$PREFIX \
        --with-z=$PREFIX \
        --with-bz2=$PREFIX \
        --without-krb5 \
        --without-gnutls \
        --without-sse42 \
        --without-gcrypt \
        --without-pcre
fi

#list apps to build
apps="blastp.exe blastn.exe blastx.exe tblastn.exe tblastx.exe psiblast.exe"
apps="$apps rpsblast.exe rpstblastn.exe makembindex.exe segmasker.exe"
apps="$apps dustmasker.exe windowmasker.exe deltablast.exe makeblastdb.exe"
apps="$apps blastdbcmd.exe blastdb_aliastool.exe convert2blastmask.exe"
apps="$apps blastdbcheck.exe makeprofiledb.exe blast_formatter.exe rpsbproc.exe"
apps="$apps blastn_vdb.exe tblastn_vdb.exe"
cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s $BLAST_SRC_DIR/c++/ReleaseMT/lib $LIB_INSTALL_DIR

cd build
echo "RUNNING MAKE"
#make -j${CPU_COUNT} -f Makefile.flat $apps
make -j1 -f Makefile.flat $apps

# remove temporary link
rm $LIB_INSTALL_DIR

mkdir -p $PREFIX/bin $LIB_INSTALL_DIR
chmod +x $BLAST_SRC_DIR/c++/ReleaseMT/bin/*
cp $BLAST_SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
cp $BLAST_SRC_DIR/c++/ReleaseMT/lib/* $LIB_INSTALL_DIR

#chmod +x $PREFIX/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/update_blastdb.pl
# Patches to enable this script to work better in bioconda
sed -i.bak 's/mktemp.*/mktemp`/; s/exit 1/exit 0/; s/^export PATH=\/bin:\/usr\/bin:/\#export PATH=\/bin:\/usr\/bin:/g' $PREFIX/bin/get_species_taxids.sh

#extra log to check all exe are present
ls -s $PREFIX/bin/
