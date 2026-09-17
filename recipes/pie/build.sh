#!/usr/bin/env bash
set -euo pipefail

# Never reuse the x86-64 binary bundled in the upstream source archive.
# setup.py declares pie.module.lib.hamming as an Extension, so pip will use
# Conda's activated C compiler and build the correct binary for this Python ABI
# and target platform.
rm -f pie/pie/module/lib/hamming.so

# Some macOS runners resolve clang through Conda's package-cache symlink.  In
# that case clang's @rpath may not include the active build environment, even
# though its matching libclang-cpp dylib is installed there.  Keep this
# version-independent and limited to the macOS build host.
if [[ "${OSTYPE:-}" == darwin* ]]; then
    export DYLD_LIBRARY_PATH="${BUILD_PREFIX}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"
fi

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
