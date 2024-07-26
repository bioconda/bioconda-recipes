#!/bin/bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


NCBI_CXX_TOOLKIT="${SRC_DIR}/ncbi_cxx/c++"
RPSBPROC_SRC="${SRC_DIR}/rpsbproc"


export CFLAGS="$CFLAGS"
export CXXFLAGS="$CXXFLAGS"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CC_FOR_BUILD=$CC

if [[ "$(uname)" = "Linux" ]]; then
	# only add things needed; not supported by OSX ld
	LDFLAGS="$LDFLAGS -Wl,-as-needed"
	export CPP_FOR_BUILD=$CPP
elif [[ "$(uname)" = "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib -lz -lbz2"

	# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi


# Embed RpsbProc into the NCBI C++ toolkit source tree
mkdir "$NCBI_CXX_TOOLKIT/src/app/RpsbProc"
cp -rf "$RPSBPROC_SRC/src/"* "$NCBI_CXX_TOOLKIT/src/app/RpsbProc/"

# Configuration synopsis:
# https://ncbi.github.io/cxx-toolkit/pages/ch_config.html#ch_config.ch_configget_synopsi
# Run `./configure --help` for all flags.

# platform-independent flags
# Description of used options (from ./configure --help):
## BUILD CHAIN OPTIONS
CONFIGURE_FLAGS=""
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
# --with(out)-with-experimental=Int8GI:
#   Enable named experimental feature:
#     Int8GI (Use a simple 64-bit type for GI numbers).
#   See c++/src/build-system/configure.ac lines 1020:1068 for the named options.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-experimental=Int8GI"
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
# static linking
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-dll --with-static-exe"

# platform-specific flags
if [[ "$(uname)" = "Linux" ]]; then
	# --with(out)-64:
	#   Compile in 64-bit mode instead of 32-bit.
	#   Flag not available for osx build.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-64"
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
# See https://linux.die.net/man/1/ar for option explanation
export AR="${AR} rcs"

cd "$NCBI_CXX_TOOLKIT/"
./configure $CONFIGURE_FLAGS

cd ReleaseMT/build
echo "RUNNING MAKE"
make -j1 -f Makefile.flat rpsbproc.exe


mkdir -p $PREFIX/bin
chmod +x $NCBI_CXX_TOOLKIT/ReleaseMT/bin/*


cp $NCBI_CXX_TOOLKIT/ReleaseMT/bin/rpsbproc* $PREFIX/bin/


#extra log to check all exe are present
ls -s $PREFIX/bin/
