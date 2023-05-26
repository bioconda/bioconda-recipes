#!/bin/bash
set -euxo pipefail

# Arrange ncbi-vdb files in a form that NCBI C++ tookit
# build can consume them.
VDB=$SRC_DIR/vdb
mkdir $VDB
if [[ $(uname) = Linux ]] ; then
   mkdir -p $VDB/linux/release/x86_64/lib
   cp -R $PREFIX/lib64/lib* $VDB/linux/release/x86_64/lib
else
   mkdir -p $VDB/mac/release/x86_64/lib
   cp -R $PREFIX/lib64/lib* $VDB/mac/release/x86_64/lib
fi
mkdir $VDB/interfaces
cp -R $PREFIX/include/ncbi-vdb/* $VDB/interfaces


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


# Fixes building on unix (linux and osx)
export AR="${AR} rcs"

./src/build-system/cmake/cmake-cfg-unix.sh --without-debug --with-dll --with-features="BinRelease;OpenMP;SSE;StaticComponents" --with-components="Z;BZ2;VDB;-LZO;-ZSTD" -DNCBI_ThirdParty_VDB=$VDB


#list apps to build
apps="blastp blastn blastx tblastn tblastx psiblast"
apps="$apps rpsblast rpstblastn makembindex segmasker"
apps="$apps dustmasker windowmasker deltablast makeblastdb"
apps="$apps blastdbcmd blastdb_aliastool convert2blastmask"
apps="$apps blastdbcheck makeprofiledb blast_formatter rpsbproc"
apps="$apps blastn_vdb tblastn_vdb blast_formatter_vdb blast_vdb_cmd"
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
