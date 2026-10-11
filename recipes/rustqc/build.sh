#!/bin/bash
set -xeuo pipefail

mkdir -p "${PREFIX}/bin"

if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: single binary per architecture, no dispatch needed
    install -m 0755 baseline/rustqc "${PREFIX}/bin/rustqc"
else
    # Linux: install baseline + SIMD variants with dispatch wrapper
    install -m 0755 baseline/rustqc "${PREFIX}/bin/rustqc-baseline"
    [ -f simd-v3/rustqc ]          && install -m 0755 simd-v3/rustqc          "${PREFIX}/bin/rustqc-avx2"
    [ -f simd-v4/rustqc ]          && install -m 0755 simd-v4/rustqc          "${PREFIX}/bin/rustqc-avx512"
    [ -f simd-neoverse-v1/rustqc ] && install -m 0755 simd-neoverse-v1/rustqc "${PREFIX}/bin/rustqc-neoverse-v1"

    cat > "${PREFIX}/bin/rustqc" << 'DISPATCH'
#!/usr/bin/env bash
BASE="$(dirname -- "${BASH_SOURCE[0]}")/rustqc"

if [ -x "${BASE}-avx512" ] && grep -q avx512 /proc/cpuinfo 2>/dev/null; then
    exec "${BASE}-avx512" "$@"
fi
if [ -x "${BASE}-avx2" ] && grep -q avx2 /proc/cpuinfo 2>/dev/null; then
    exec "${BASE}-avx2" "$@"
fi
if [ -x "${BASE}-neoverse-v1" ] && grep -q sve /proc/cpuinfo 2>/dev/null; then
    exec "${BASE}-neoverse-v1" "$@"
fi
exec "${BASE}-baseline" "$@"
DISPATCH
    chmod 0755 "${PREFIX}/bin/rustqc"
fi
