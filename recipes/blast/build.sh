#!/bin/bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


export BLAST_SRC_DIR="${SRC_DIR}/blast"
cd $BLAST_SRC_DIR/c++/

export CFLAGS="$CFLAGS"
export CXXFLAGS="$CXXFLAGS"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CC_FOR_BUILD=$CC

if [[ "$(uname)" = "Linux" ]]; then
	# only add things needed; not supported by OSX ld
	LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

if [[ "$(uname)" = "Darwin" ]]; then
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
# Run `./configure --help` for all flags.

# platform-independent flags
CONFIGURE_FLAGS=""
# Description of used options (from ./configure --help):
# --with(out)-bin-release:
#   Build executables suitable for public release
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-bin-release"
# --with(out)-mt:
#   Compile in a multi-threading safe manner.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-mt"
# --with(out)-autodep:
#   Automatic dependency build (one time build).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-autodep"
# --with(out)-makefile-auto-update:
#   Rebuild of makefile (one time build).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-makefile-auto-update"
# --with(out)-flat-makefile:
#   Use single makefile.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-flat-makefile"
# --with(out)-caution:
#   Proceed configuration without asking when in doubt.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-caution"
# --with(out)-lzo:
#   Add lzo support (compression lib, req. lzo >2.x).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-lzo"
# --with(out)-debug:
#   Strip -D_DEBUG and -g, engage -DNDEBUG and -O.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-debug"
# --with(out)-with-experimental=Int8GI:
#   Enable named experimental feature: Int8GI (Use a simple 64-bit type for GI numbers).
#   See c++/src/build-system/configure.ac lines 1020:1068 for the named options.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-experimental=Int8GI"
# --with(out)-strip:
#   Strip binaries at build time (remove debugging symbols)
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-strip"
# --with(out)-vdb:
#   Enable VDB/SRA toolkit.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-vdb=$PREFIX"
# --with(out)-z:
#   Set zlib path (compression lib).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-z=$PREFIX"
# --with(out)-bz2:
#   Set bzlib path (compression lib).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-bz2=$PREFIX"
# --with(out)-krb5:
#   Enable kerberos (needed on OSX).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-krb5"
# --with(out)-gnutls:
#   Enable gnutls.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gnutls"
# --with(out)-sse42
#   Disable SSE 4.2 when optimizing.
#   Many CPU's don't have this instruction set
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-sse42"

# platform-specific flags
if [[ "$(uname)" = "Linux" ]]; then
	# --with(out)-64:
	#   Compile in 64-bit mode instead of 32-bit.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-64"
	# --with(out)-dll:
	#   Use dynamic instead of static linking.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-dll"
	# --with(out)-runpath:
	#   Set runpath for installed $PREFIX location.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-runpath=$LIB_INSTALL_DIR"
	# --with(out)-hard-runpath:
	#   Hard-code runtime path, ignoring LD_LIBRARY_PATH
	#   (disallow LD_LIBRARY_PATH override on Linux).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-hard-runpath"
	# --with(out)-openmp:
	#   Enable OpenMP extensions for all projects.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-openmp"
else
	# --with(out)-openmp:
	#   Disable OpenMP extensions for all projects.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-openmp"
	# --with(out)-pcre:
	#   Enable pcre (Perl regex).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-pcre"
	# --with(out)-gcrypt:
	#   Disable gcrypt (needed on OSX).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gcrypt"
	# --with(out)-zstd:
	#   Do not use Zstandard.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-zstd"
fi

# Fixes building on unix (linux and osx)
export AR="${AR} rcs"

./configure $CONFIGURE_FLAGS

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
# only use 1 job, as this may already use 10GiB of RAM
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
