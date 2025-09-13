#!/bin/bash -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

if [[ ${target_platform}  == "linux-aarch64" ]]; then
        export CARGO_BUILD_TARGET=aarch64-unknown-linux-gnu
        export RUSTFLAGS="-C linker=aarch64-conda-linux-gnu-cc "
        export CFLAGS="-fno-dse"
        export CXXFLAGS="${CFLAGS}"
        cargo fetch
        git clone https://github.com/markschl/seq_io.git
        cargo clean
        sed -i '74,98s|^|//|' .cargo/registry/src/index.crates.io-1949cf8c6b5b557f/fasthash-sys-0.3.2/build.rs
        sed -i.bak 's|-msse4.2||'  .cargo/registry/src/index.crates.io-1949cf8c6b5b557f/fasthash-sys-0.3.2/src/smhasher/doc/crcutil
        sed -i "12c twox-hash = \"1.6.3\" " Cargo.toml
	sed -i "35c seq_io = \"0.4.0-alpha.0\" " Cargo.toml
fi
RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX
