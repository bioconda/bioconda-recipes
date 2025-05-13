#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export PYO3_PYTHON="${PYTHON}"

sed -i.bak 's|maturin>=0.13,<0.14|maturin>=1.8.0,<2.0.0|' rust/pyproject.toml
sed -i.bak 's|"0.40.2"|"0.47.0"|' rust/Cargo.toml
sed -i.bak 's|"0.18.1"|"0.21.2"|' rust/Cargo.toml
sed -i.bak 's|"0.18.3"|"0.21.2"|' rust/Cargo.toml
rm -rf rust/*.bak

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
	export CARGO_BUILD_TARGET="x86_64-unknown-linux-musl"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export CARGO_BUILD_TARGET="aarch64-unknown-linux-musl"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
cd rust
RUSTFLAGS="-C target-feature=-crt-static" maturin build --interpreter "${PYTHON}" --release --strip -b pyo3 --target "${CARGO_BUILD_TARGET}"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

# build statically linked binary with Rust
#RUST_BACKTRACE=1
#if [[ "${OS}" == "Darwin" ]]; then
  #RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
#else
  #RUSTFLAGS="-C target-feature=-crt-static -L ${PREFIX}/lib64" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
#fi
