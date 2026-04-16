#!/bin/bash
set -euo pipefail

# Prevent scikit-build-core from stripping the binary so conda-build's
# llvm-otool can successfully parse the Mach-O headers for rpath fixup.
export SKBUILD_INSTALL_STRIP=false

# Force the classic macOS linker to avoid Xcode 15+ ld-prime format
# incompatibilities with conda's LLVM tools.
if [[ "${OSTYPE:-}" == darwin* ]]; then
    export LDFLAGS="${LDFLAGS:-} -Wl,-ld_classic"
fi

$PYTHON -m pip install . --no-deps --no-build-isolation -vv
