#!/bin/bash
set -ex

export CXXFLAGS="${CXXFLAGS} -O3"

# Use conda-forge's htslib (host/run dep) instead of building the bundled
# submodule. ext/htslib stays in place because the Makefile has explicit
# dependency rules listing ext/htslib/htslib/*.h as prereqs of bwa-mem3's
# object files; deleting the dir breaks those rules. Instead the bundled
# 1.21 headers stay on the include path for compilation, while linking
# resolves -lhts via conda's -L${PREFIX}/lib (which precedes the bundled
# -Lext/htslib in the link line). The Makefile's $(HTS_LIB): rule has no
# prerequisites, so when HTS_LIB points at an already-existing file make
# treats it as up-to-date and skips the autoreconf+configure+make chain.
# The 1.21->1.23 ABI drift across bwa-mem3's small htslib API surface
# (hts_open/close, sam_hdr_init/add_line/add_lines/destroy/write,
# bam_aux_append) is zero -- all stable since htslib 1.0.

MAKE_ARGS=(
  -j${CPU_COUNT}
  CC="${CC}"
  CXX="${CXX}"
  # safestringlib's safeclib_private.h calls abort()/memcpy() via macros
  # without including <stdlib.h>/<string.h>. bwa-mem3's Makefile force-
  # includes them for clang/Darwin only; modern conda gcc on Linux also
  # promotes -Wimplicit-function-declaration to an error.
  SAFE_EXTRA_CFLAGS="-include stdlib.h -include ctype.h"
  # bwa-mem3's Makefile derives VERSION_STRING from `git describe`; the
  # source tarball has no .git, so set the version explicitly.
  VERSION_STRING="${PKG_VERSION}"
  # Compile-time SIMD floor for non-kernel TUs (x86_64 only; the Makefile
  # ignores this on aarch64/arm64). The runtime dispatcher in
  # src/simd_dispatch.cpp (PR #83) selects the right kernel tier per host
  # from all five compiled kernel tiers. avx2 is upstream's distribution
  # default; per docs/src/whats-different/avx512-baseline.md the cold-path
  # delta to a host-locked avx512bw build is ~2-4% on Zen 4 and <1% on
  # Sapphire Rapids -- not worth a multi-binary split. Pre-AVX2 hosts
  # (Sandy/Ivy Bridge, Bulldozer/Piledriver, older Atom) are not
  # supported by this build.
  BASELINE_ARCH=avx2
)

if [ "$(uname)" = "Darwin" ]; then
  # The Makefile's macOS branch expects LIBOMP_PREFIX to point at a directory
  # containing include/ and lib/libomp.dylib. The conda llvm-openmp package
  # installs both under ${PREFIX}.
  MAKE_ARGS+=( LIBOMP_PREFIX="${PREFIX}" )
  # Use conda-forge's mimalloc and htslib instead of building bundled
  # submodules. The Makefile's $(MIMALLOC_LIB): and $(HTS_LIB): rules have
  # no prerequisites, so pointing them at already-existing files makes
  # make treat them as up-to-date.
  MAKE_ARGS+=(
    MIMALLOC_LIB="${PREFIX}/lib/libmimalloc.dylib"
    MIMALLOC_LDFLAGS="-L${PREFIX}/lib -lmimalloc -Wl,-rpath,${PREFIX}/lib"
    HTS_LIB="${PREFIX}/lib/libhts.dylib"
  )
else
  # bwa-mem3 calls shm_open/shm_unlink, which on conda's CentOS-7 sysroot
  # (glibc 2.17) live in librt. Newer Linux glibc (>= 2.34) folds them
  # into libc, so upstream CI on ubuntu-latest doesn't need this.
  MAKE_ARGS+=( LIBS_EXTRA="-lrt" )
  # Use conda-forge's mimalloc and htslib. conda-forge ships only the
  # shared library form on Linux (no .a), so switch from the upstream
  # Makefile's `-Wl,--whole-archive libmimalloc.a -Wl,--no-whole-archive`
  # static linking to dynamic linking. mimalloc's docs note that placing
  # `-lmimalloc` before `-lc` in link order is sufficient for malloc
  # interposition via ELF symbol resolution order; the upstream LIBS
  # variable already places $(MIMALLOC_LDFLAGS) before the implicit -lc.
  MAKE_ARGS+=(
    MIMALLOC_LIB="${PREFIX}/lib/libmimalloc.so"
    MIMALLOC_LDFLAGS="-L${PREFIX}/lib -lmimalloc -Wl,-rpath,${PREFIX}/lib"
    HTS_LIB="${PREFIX}/lib/libhts.so"
  )
fi

make "${MAKE_ARGS[@]}"

mkdir -p "${PREFIX}/bin"
install -v -m 0755 bwa-mem3 "${PREFIX}/bin/"
