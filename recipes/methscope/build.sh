#!/bin/bash
set -euo pipefail

# SHARED VERBATIM by both recipes -- conda-recipe/ (zhou-lab channel) and
# bioconda-recipe/ (bioconda). They cannot be one physical file (the bioconda
# copy is submitted to the separate bioconda-recipes repo), so the two are kept
# byte-identical; edit them TOGETHER. Verify: diff conda-recipe/build.sh
# bioconda-recipe/build.sh.

# XGB_PREFIX points the Makefile at the build env's include/ and lib/ for
# libxgboost. The Makefile bakes -Wl,-rpath,$XGB_PREFIX/lib; conda-build's
# post-processing relocates that to an $ORIGIN-relative RPATH, so the installed
# binary finds libxgboost without activating any env.

# Our own Makefile declares CFLAGS with ?=, so conda's CFLAGS wins; re-add the
# -std=gnu99 the sources expect, plus CPPFLAGS (which the Makefile never reads).
export CFLAGS="${CFLAGS:-} ${CPPFLAGS:-} -std=gnu99"

# Both vendored Makefiles hard-assign their own CFLAGS (YAME: `CFLAGS = -W
# -Wall ...`, htslib: `CFLAGS = -g -Wall`), so conda's -isystem $PREFIX/include
# reaches neither, and their sources include <zlib.h>. Overriding CFLAGS on the
# make command line is not an option: a command-line variable beats a Makefile
# `+=` too, which would strip YAME's own -Isrc -Ihtslib. htslib's rule does
# honor CPPFLAGS, but YAME's does not, so no single make variable covers both.
# C_INCLUDE_PATH sidesteps the Makefiles entirely -- the compiler reads it
# directly -- and so reaches every sub-make regardless of its flag discipline.
# macOS did not need this because the SDK ships zlib.h on the default search
# path; the Linux sysroot does not.
export C_INCLUDE_PATH="${PREFIX}/include${C_INCLUDE_PATH:+:${C_INCLUDE_PATH}}"

# LDFLAGS must be passed on the command line: our Makefile assigns it outright
# (LDFLAGS = -L... -Wl,-rpath,...), which would otherwise discard conda's
# sysroot and rpath settings. This is safe to pass here because the vendored
# libraries are static archives (ar), so they never consume LDFLAGS.
make -j"${CPU_COUNT:-1}" CC="${CC}" XGB_PREFIX="${PREFIX}" \
     LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib ${LDFLAGS:-}"

# Not `install -D`: that is a GNU coreutils extension and BSD/macOS install
# rejects it.
mkdir -p "${PREFIX}/bin"
install -m 755 methscope "${PREFIX}/bin/methscope"
