#!/bin/bash -euo

if [[ "${target_platform}"  == "linux-aarch64" ]]; then
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

RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "$PREFIX"
