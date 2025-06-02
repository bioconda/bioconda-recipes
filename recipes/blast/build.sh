#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


# Source path
BLAST_SRC_DIR="$SRC_DIR/c++"
# Work directory
RESULT_PATH="$BLAST_SRC_DIR/Release"


# C/C++ preprocessor header includes paths
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
# Linker library paths
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
# C++ compiler flags
if [[ "$(uname)" = "Darwin" ]]; then
	# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
	export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

LIB_INSTALL_DIR="$PREFIX/lib/ncbi-blast+"

# Configuration synopsis:
# https://ncbi.github.io/cxx-toolkit/pages/ch_config.html#ch_config.ch_configget_synopsi
# Run `./configure --help` for all flags.
CONFIGURE_FLAGS="--with-build-root=$RESULT_PATH"

# platform-independent flags
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
#   - PSGLoader    Let the GenBank data loader use PubSeq Gateway (PSG).
#   - BM64         Use 64-bit bitset indices.
#   - C++20        Use '-std=gnu++20' compiler flag.
#   - C2X          Use '-std=gnu2x' compiler flag.
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
#   Old CPU's (read: released befor 2012) may not have this instruction set.
#   We can consider removing this, considering the NCBI builds enable this now.
#   See: https://github.com/bioconda/bioconda-recipes/pull/17677
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-sse42"

## LIBRARIES
# --with(out)-pcre:
#   Do not use pcre (Perl regex).
#   The NCBI release builds also pass this.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-pcre"
# --with(out)-lzo:
#   Do not add lzo support (compression lib, req. lzo >2.x).
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-lzo"
# --with(out)-vdb:
#   Enable VDB/SRA toolkit.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-vdb=$PREFIX"
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
#   Do not use Kerberos 5.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-krb5"
# --with(out)-gnutls:
#   Do not use gnutls.
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gnutls"
# --with(out)-boost:
#   Do not use Boost.
#   It tries to search for it and prints some warnings, so might as well tell it beforehand.
#   See: https://github.com/bioconda/bioconda-recipes/pull/15754
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-boost"

# platform-specific flags
if [[ "$(uname)" = "Linux" ]]; then
	# --with(out)-64:
	#   Compile in 64-bit mode instead of 32-bit.
	#   Flag not available for osx build.
        if [[ "$(arch)" = "x86_64" ]]; then
            CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-64"
	fi
	# --with(out)-openmp:
	#   Enable OpenMP extensions for all projects.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-openmp"

	## LINKING
	# Dynamically link libraries
	# --with(out)-dll:
	#   Use dynamic instead of static library linking.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-dll"
	# --with(out)-runpath:
	#   Set runpath for installed $PREFIX location.
	#   Needed for --with-dll.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-runpath=$LIB_INSTALL_DIR"
	# --with(out)-hard-runpath:
	#   Hard-code runtime path, ignoring LD_LIBRARY_PATH
	#   (disallow LD_LIBRARY_PATH override on Linux).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-hard-runpath"
else
	# --with(out)-openmp:
	#   Disable OpenMP extensions for all projects.
	#   Does not work without hacks for OSX
	#   See: https://github.com/bioconda/bioconda-recipes/pull/40555
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-openmp"
	# --with(out)-gcrypt:
	#   Do not use gcrypt (needed on OSX).
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-gcrypt"
	# --with(out)-zstd:
	#   Do not use Zstandard.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-zstd"

	## LINKING
	# Build statically linked programs. For some reason it raises segfaults during compilation on
	# osx-64 when trying a dynamically linked build.
	# --with-static --with(out)-dll:
	#   Use static instead of dynamic library linking.
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-static --without-dll"
fi

# Fixes building on unix (linux and osx)
export AR="${AR} rcs"

# Run configure script
cd "$BLAST_SRC_DIR"
./configure $CONFIGURE_FLAGS >&2


# Run GNU Make
# List of apps to build
apps="\
blast_formatter.exe \
blastdb_aliastool.exe \
blastdbcheck.exe \
blastdbcmd.exe \
blastn_vdb.exe \
blastn.exe \
blastp.exe \
blastx.exe \
convert2blastmask.exe \
deltablast.exe \
dustmasker.exe \
makeblastdb.exe \
makembindex.exe \
makeprofiledb.exe \
psiblast.exe \
rpsblast.exe \
rpstblastn.exe \
segmasker.exe \
tblastn_vdb.exe \
tblastn.exe \
tblastx.exe \
windowmasker.exe \
"

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s "$RESULT_PATH/lib" "$LIB_INSTALL_DIR"

cd "$RESULT_PATH/build"
echo "RUNNING MAKE" >&2
make -j 4 -f Makefile.flat $apps >&2

# remove temporary link
rm "$LIB_INSTALL_DIR"

# Copy compiled binaries to the Conda $PREFIX
mkdir -p "$PREFIX/bin"
chmod +x "$RESULT_PATH/bin/"*
cp "$RESULT_PATH/bin/"* "$PREFIX/bin/"
# Copy compiled libraries to the Conda $PREFIX
if [[ "$(uname)" = "Linux" ]]; then
	# Not necessary for osx as that is statically linked
	mkdir -p "$LIB_INSTALL_DIR"
	cp "$RESULT_PATH/lib/"* "$LIB_INSTALL_DIR"
fi

# Patch Perl shebangs
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' "$PREFIX/bin/update_blastdb.pl"
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' "$PREFIX/bin/legacy_blast.pl"
# Patch Python2 shebangs
sed -i.bak '1 s|^.*$|#!/usr/bin/env python|g' "$PREFIX/bin/windowmasker_2.2.22_adapter.py"
# remove the sed backup files
rm -f -v "$PREFIX/bin/"*.bak

# Extra log to check results
ls -lhAF "$PREFIX/bin/"
