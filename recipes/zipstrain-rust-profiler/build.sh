#!/bin/bash
set -euo pipefail

export CARGO_BUILD_JOBS="${CPU_COUNT}"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
