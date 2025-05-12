#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -fcommon"
#export PYO3_PYTHON="${PYTHON}"
unamestr=`uname`

sed -i.bak 's|maturin>=0.13,<0.14|maturin>=1.8.0,<2.0.0|' rust/pyproject.toml
rm -rf rust/*.bak

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable --profile=minimal -y
export PATH="${HOME}/.cargo/bin:${PATH}"

RUST_BACKTRACE=full
if [[ "$unamestr" == 'Darwin' ]]; then
  RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
else
  RUSTFLAGS="-L ${PREFIX}/lib64 -C linker=${CC}" cargo install -v --no-track --locked --path rust/ --root "${PREFIX}"
fi

cd rust
maturin build -f --release --strip -b pyo3

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
