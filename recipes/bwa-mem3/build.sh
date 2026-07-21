#!/bin/bash
set -ex

export CXXFLAGS="${CXXFLAGS} -O3"

# Use conda-forge htslib instead of building the bundled submodule.
# ext/htslib stays on disk because the Makefile has explicit prereqs
# on ext/htslib/htslib/*.h; pointing HTS_LIB at the conda-forge file
# makes the bundled $(HTS_LIB): rule a no-op and -lhts resolves via
# -L${PREFIX}/lib. The meta.yaml htslib pin keeps the bundled headers
# ABI-compatible with the conda shared library.

MAKE_ARGS=(
  -j${CPU_COUNT}
  CC="${CC}"
  CXX="${CXX}"
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
  # Use conda-forge libsais: clearing LIBSAIS_OBJS skips the bundled
  # compile, and -lsais (in LIBS_EXTRA below) resolves the symbols.
  # The meta.yaml libsais pin keeps the bundled headers in
  # ext/libsais/include ABI-compatible with the conda shared library.
  LIBSAIS_OBJS=""
)

# Use conda-forge sse2neon on ARM: overriding SSE2NEON_INCLUDES replaces
# the bundled -Iext/sse2neon with the conda-forge header location. The
# conda-forge package installs the header at ${PREFIX}/include/sse2neon/
# (subdir), so the include path points one level deeper to let
# bwa-mem3's `#include "sse2neon.h"` resolve. ARM-only because the
# Makefile only references sse2neon under its IS_ARM branch.
case "$(uname -m)" in
  aarch64|arm64)
    MAKE_ARGS+=( SSE2NEON_INCLUDES="-I${PREFIX}/include/sse2neon" )
    ;;
esac

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
    LIBS_EXTRA="-L${PREFIX}/lib -lsais -Wl,-rpath,${PREFIX}/lib"
  )
else
  # bwa-mem3 calls shm_open/shm_unlink, which on conda's CentOS-7 sysroot
  # (glibc 2.17) live in librt. Newer Linux glibc (>= 2.34) folds them
  # into libc, so upstream CI on ubuntu-latest doesn't need this.
  #
  # mimalloc: build and statically link the bundled ext/mimalloc submodule
  # (the Makefile's default `-Wl,--whole-archive libmimalloc.a`) rather than
  # dynamically linking conda-forge's libmimalloc.so. conda-forge's Linux
  # libmimalloc.so exports only the mi_* API, NOT an overriding malloc/free
  # (it is built without MI_OVERRIDE symbol interposition). Dynamically
  # linking it therefore loads mimalloc but leaves every malloc/free on the
  # system allocator -- `bwa-mem3 version` still prints a mimalloc version
  # (mi_version() resolves), but the hot alignment path runs on glibc malloc,
  # costing ~30% wall on multi-threaded WGS. The `-lmimalloc before -lc`
  # interposition claimed by the old comment here only holds when the .so
  # exports malloc, which conda-forge's does not. Static whole-archive of the
  # bundled MI_OVERRIDE=ON libmimalloc.a is the only robust override on Linux,
  # so we drop the MIMALLOC_LIB/MIMALLOC_LDFLAGS overrides and let the
  # Makefile default build the vendored allocator. (macOS is unaffected: there
  # conda's libmimalloc.dylib interposes via dyld __interpose regardless of
  # symbol export, so the Darwin branch above keeps the conda-forge mimalloc.)
  MAKE_ARGS+=(
    HTS_LIB="${PREFIX}/lib/libhts.so"
    LIBS_EXTRA="-lrt -L${PREFIX}/lib -lsais -Wl,-rpath,${PREFIX}/lib"
  )
fi

make "${MAKE_ARGS[@]}"

mkdir -p "${PREFIX}/bin"
install -v -m 0755 bwa-mem3 "${PREFIX}/bin/"
