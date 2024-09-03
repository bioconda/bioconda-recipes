#!/bin/bash -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

if [ `uname -m` == "aarch64" ]; then
    TARGET_CPUS=("aarch64")
else # x86-64
    TARGET_CPUS=("x86-64" "x86-64-v2" "x86-64-v3" "x86-64-v4")
fi

for TARGET_CPU in "${TARGET_CPUS[@]}"; do
    # build statically linked binary with Rust
    CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true RUST_BACKTRACE=1 RUSTFLAGS="-C target-cpu=${TARGET_CPU}" cargo install --verbose --path . --root $PREFIX
    mv ${PREFIX}/bin/sylph ${PREFIX}/bin/_sylph_${TARGET_CPU}
done


cp "${RECIPE_DIR}/sylph" "${PREFIX}/bin/sylph"
chmod +x "${PREFIX}/bin/sylph"
