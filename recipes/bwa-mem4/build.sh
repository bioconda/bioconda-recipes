#!/bin/bash -euo

set -xe

# Point htslib's build (via hts-sys) and bindgen at the conda prefix's headers and libraries.
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS:-} -O3 -Wno-deprecated-declarations"
# hts-sys uses bindgen to wrap htslib; make sure it sees the same include/lib flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

# Override the repo's .cargo/config.toml `-C target-cpu=native`, which would bake in the build
# host's CPU and SIGILL on older ones. The SIMD kernels are chosen at runtime, so nothing is lost.
export RUSTFLAGS=""
if [[ -n "${OSX_ARCH:-}" ]]; then
  export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# The workspace declares rust-version 1.96, but the code actually compiles on far older toolchains
# (verified: `cargo check` is clean on rust 1.91). Bioconda's osx-64 provides rust 1.95 -- the newest
# build that still targets macOS 10.13 -- and forcing rust 1.96 there instead pulls in a macOS 11.0
# requirement osx-64 cannot satisfy. So relax the declared MSRV to let the platform's own toolchain
# build it. rust-version is not part of Cargo.lock, so --locked is unaffected.
sed -i.bak 's/^rust-version = "1.96"/rust-version = "1.95"/' Cargo.toml && rm -f Cargo.toml.bak

# Bioconda requires the bundled third-party (vendored crate) licenses.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build and install only the binary crate. --locked pins the committed Cargo.lock.
RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --path crates/bwa-cli --root "${PREFIX}"
