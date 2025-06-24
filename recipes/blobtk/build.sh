#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export PYO3_PYTHON="${PYTHON}"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CC_x86_64_unknown_linux_gnu="${CC}"
export CXX_x86_64_unknown_linux_gnu="${CXX}"
export AR_x86_64_unknown_linux_gnu="${AR}"

cp -f ${RECIPE_DIR}/LICENSE .
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

sed -i.bak 's|"0.40.2"|"0.47.1"|' Cargo.toml
sed -i.bak 's|"0.18.1"|"0.21.2"|' Cargo.toml
sed -i.bak 's|"0.18.3"|"0.21.2"|' Cargo.toml
rm -rf *.bak

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
	export TARG="x86_64-unknown-linux-gnu"
	rustup target add x86_64-unknown-linux-gnu
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export TARG="aarch64-unknown-linux-gnu"
	rustup target add aarch64-unknown-linux-gnu
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export TARG="aarch64-apple-darwin"
else
	export TARG="x86_64-apple-darwin"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
if [[ "${OS}" == "Linux" ]]; then
	RUSTFLAGS="-C target-feature=+crt-static -L ${PREFIX}/lib" maturin build --interpreter "${PYTHON}" --release --strip -b pyo3
else
	RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" maturin build --interpreter "${PYTHON}" --release --strip -b pyo3
fi

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
