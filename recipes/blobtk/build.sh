#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export PYO3_PYTHON="${PYTHON}"
unamestr=`uname`

sed -i.bak 's|maturin>=0.13,<0.14|maturin>=1.8.0,<2.0.0|' rust/pyproject.toml
sed -i.bak 's|"0.40.2"|"0.47.0"|' rust/Cargo.toml
sed -i.bak 's|"0.18.1"|"0.21.2"|' rust/Cargo.toml
sed -i.bak 's|"0.18.3"|"0.21.2"|' rust/Cargo.toml
rm -rf rust/*.bak

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

# build statically linked binary with Rust
RUST_BACKTRACE=1
if [[ "$unamestr" == "Darwin" ]]; then
  RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
else
  RUSTFLAGS="-C target-feature=-crt-static -L ${PREFIX}/lib64" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
fi
