#!/usr/bin/env bash
set -euo pipefail

# Never reuse the x86-64 binary bundled in the upstream source archive.
# setup.py declares pie.module.lib.hamming as an Extension, so pip will use
# Conda's activated C compiler and build the correct binary for this Python ABI
# and target platform.
rm -f pie/pie/module/lib/hamming.so

# Some macOS runners resolve clang through Conda's package-cache symlink, whose
# @rpath may not include the active build environment.  Use a fallback path
# only while pip and its compiler children run; leaking a DYLD path into
# conda-build's later llvm-otool step can override macOS system libraries.
if [[ "${OSTYPE:-}" == darwin* ]]; then
    DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-/usr/local/lib:/usr/lib}" \
        "${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
else
    "${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
fi
