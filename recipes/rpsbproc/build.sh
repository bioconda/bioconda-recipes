#!/bin/bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


# For debugging ./configure
cat << EOF >&2
ENVIRONMENT
-----------
uname -a   $(uname -a)
 KERNEL
uname -s   $(uname -s)
uname -r   $(uname -r)
uname -v   $(uname -v)
 ARCHITECTURE
uname -m   $(uname -m)
EOF


# Source paths
NCBI_CXX_TOOLKIT="$SRC_DIR/ncbi_cxx/c++"
RPSBPROC_SRC="$SRC_DIR/rpsbproc"
# Work directory
RESULT_PATH="$NCBI_CXX_TOOLKIT/Release"


# C/C++ preprocessor header includes paths
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
# Linker library paths
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
# C++ compiler flags
if [[ "$(uname)" = "Darwin" ]]; then
	# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
	export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
fi


# Embed RpsbProc into the NCBI C++ toolkit source tree
mkdir "$NCBI_CXX_TOOLKIT/src/app/RpsbProc"
cp -rf "$RPSBPROC_SRC/src/"* "$NCBI_CXX_TOOLKIT/src/app/RpsbProc/"


# Configuration synopsis:
# https://ncbi.github.io/cxx-toolkit/pages/ch_config.html#ch_config.ch_configget_synopsi
# Run `./configure --help` for all flags.
CONFIGURE_FLAGS="--with-build-root=$RESULT_PATH"

# Platform-independent flags
## BUILD CHAIN OPTIONS
# --with(out)-bin-release:
#   Build executables suitable for public release
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-bin-release"
# --with(out)-debug:
#   Build non-debug versions of libs and apps.
#   Strips -D_DEBUG and -g, engage -DNDEBUG and -O.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-debug"
# --with(out)-strip:
#   Strip binaries at build time (remove debugging symbols)
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-strip"
# --with-experimental={ChaosMonkey,Int4GI,Int8GI,StrictGI,PSGLoader,BM64,C++20,C2X}:
#   Enable named experimental feature (comma-separated list):
#   - ChaosMonkey  Enable "ChaosMonkey" failure testing.
#   - Int4GI       Use a simple 32-bit type for GI numbers.
#   - Int8GI       Use a simple 64-bit type for GI numbers.
#   - StrictGI     Use a strict 64-bit type for GI numbers.
#   - PSGLoader    Let the GenBank date loader use PubSeq Gateway (PSG).
#   - BM64         Use 64-bit bitset indices.
#   - C++20        Use '-std=gnu++20' compiler flag.
#   - C2X          Use '-std=gnu2x' compiler flag.
#   See c++/src/build-system/configure.ac lines 1020:1068 for the named options.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-experimental=Int4GI"
# --with(out)-mt:
#   Compile in a multi-threading safe manner.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-mt"
# --with(out)-autodep:
#   Do not automatically generate dependencies (one time build).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-autodep"
# --with(out)-makefile-auto-update:
#   Do not auto-update generated makefiles (one time build).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-makefile-auto-update"
# --with(out)-flat-makefile:
#   Generate an all-encompassing flat makefile.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-flat-makefile"
# --with(out)-caution:
#   Proceed configuration without asking when in doubt.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-caution"
# --with(out)-sse42
#   Disable SSE 4.2 when optimizing.
#   Old CPU's (read: 10+ years) don't have this instruction set.
#   We can consider removing this.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-sse42"

## LIBRARIES
# --with(out)-lzo:
#   Do not add lzo support (compression lib, req. lzo >2.x).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-lzo"
# --with(out)-z:
#   Set zlib path (compression lib).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-z=$PREFIX"
# --with(out)-bz2:
#   Set bzlib path (compression lib).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-bz2=$PREFIX"
# --with(out)-sqlite3:
#   Set sqlite3 path (local database lib).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-sqlite3=$PREFIX"
# --with(out)-krb5:
#   Do not use Kerberos 5 (needed on OSX).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-krb5"
# --with(out)-gnutls:
#   Do not use gnutls.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gnutls"
# --with(out)-boost:
#   Do not use Boost.
#   It tries to search for it and prints some warnings, so might as well tell it beforehand.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-boost"
# --with(out)-pcre:
#   Do not use pcre (Perl regex).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-pcre"
# Static linking of libraries
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-dll --with-static-exe"

# Platform-specific flags
if [[ "$(uname)" = "Linux" ]]; then
	# --with(out)-64:
	#   Compile in 64-bit mode instead of 32-bit on x86_64 platforms.
	#   Flag not available for osx build.
        if [[ "$(arch)" = "x86_64" ]]; then
	    CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-64"
	fi
	# --with(out)-openmp:
	#   Enable OpenMP extensions for all projects.
	#   Does not work without hacks for OSX
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-openmp"
else
	# --with(out)-openmp:
	#   Disable OpenMP extensions for all projects.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-openmp"
	# --with(out)-gcrypt:
	#   Do not use gcrypt (needed on OSX).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gcrypt"
	# --with(out)-zstd:
	#   Do not use Zstandard.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-zstd"
fi

# Fixes building on unix (linux and osx)
export AR="${AR} rcs"

# Run configure script
cd "$NCBI_CXX_TOOLKIT"
./configure.orig $CONFIGURE_FLAGS >&2

# Run GNU Make
cd "$RESULT_PATH/build"
echo "RUNNING MAKE" >&2
make -j 4 -f Makefile.flat rpsbproc.exe >&2

# Copy compiled binaries to the Conda $PREFIX
mkdir -p "$PREFIX/bin"
chmod +x "$RESULT_PATH/bin/"*
cp "$RESULT_PATH/bin/rpsbproc"* "$PREFIX/bin/"

# Extra log to check results
ls -lhAF "$PREFIX/bin/"
