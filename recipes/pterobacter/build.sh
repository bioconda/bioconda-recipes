#!/usr/bin/env bash
set -euo pipefail

# These checks execute the installed binaries. Use a native runner for each
# platform rather than silently skipping runtime validation in a cross-build.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    echo "Pterobacter packaging requires a native build/test runner." >&2
    exit 1
fi

export CARGO_BUILD_JOBS="${CPU_COUNT}"
# Build for the selected Conda platform, without host-specific CPU tuning.
export CXXFLAGS="${CXXFLAGS:-} -std=c++17"
if [[ "${target_platform}" == osx-* ]]; then
    # Upstream selects the runtime and Darwin ARM ABI for this GNU toolchain.
    export PTERO_CXX_STDLIB=c++
fi
cargo fetch --locked
python scripts/bundle_licenses.py --distribution THIRDPARTY.yml
# Exercise runtime selection as well as the installed native smoke test below.
cargo test --locked --test native_compiler -- --test-threads=1
# Exercise atomic activation and refusal paths.
cargo test --locked --lib cli::database::install::tests -- --test-threads=1
cargo install -v --locked --no-track --root "$PREFIX" --path . --bin ptero --bin pterobacter

# The upstream smoke test exercises both installed commands and embedded ANIm
# using synthetic inputs, with no reference download or analysis tools on PATH.
# Give it only these two binaries, rather than the rest of the Conda prefix.
smoke_bin=$(mktemp -d)
trap 'rm -rf "$smoke_bin"' EXIT
ln -s "$PREFIX/bin/ptero" "$smoke_bin/ptero"
ln -s "$PREFIX/bin/pterobacter" "$smoke_bin/pterobacter"
TEROBACTER_INSTALLED_BIN="$smoke_bin" \
  cargo test --locked --test installed_smoke -- --ignored --test-threads=1 --nocapture
