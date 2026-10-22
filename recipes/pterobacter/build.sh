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
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
# Exercise atomic activation and refusal paths after the Linux syscall patch.
cargo test --locked --lib cli::database::install::tests -- --test-threads=1
cargo install -v --locked --no-track --root "$PREFIX" --path . --bin ptero --bin pterobacter

# Temporary Mac diagnostic; the installed smoke test remains the acceptance gate.
if [[ "${target_platform}" == osx-* ]]; then
    native_archives=(target/"${CARGO_BUILD_TARGET}"/release/build/pterobacter-*/out/libtero_anim.a)
    test "${#native_archives[@]}" -eq 1
    "${CXX}" ${CXXFLAGS} "${RECIPE_DIR}/native-diagnostic.cc" "${native_archives[0]}" \
        ${LDFLAGS:-} -pthread -o native-diagnostic
    otool -L "$PREFIX/bin/ptero"
    otool -L native-diagnostic
    xcrun lldb --batch -o run -o 'thread backtrace all' -- ./native-diagnostic \
        tests/fixtures/anim/identical.r.fa tests/fixtures/anim/identical.q.fa native-probe || true
fi

# The upstream smoke test exercises both installed commands and embedded ANIm
# using synthetic inputs, with no reference download or analysis tools on PATH.
# Give it only these two binaries, rather than the rest of the Conda prefix.
smoke_bin=$(mktemp -d)
trap 'rm -rf "$smoke_bin"' EXIT
ln -s "$PREFIX/bin/ptero" "$smoke_bin/ptero"
ln -s "$PREFIX/bin/pterobacter" "$smoke_bin/pterobacter"
TEROBACTER_INSTALLED_BIN="$smoke_bin" \
  cargo test --locked --test installed_smoke -- --ignored --test-threads=1 --nocapture
