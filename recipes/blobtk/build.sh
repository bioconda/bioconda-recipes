#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak 's|maturin>=0.13,<0.14|maturin>=1.8.0,<2.0.0|' rust/pyproject.toml
rm -rf rust/*.bak

RUST_BACKTRACE=full
cargo install -v --no-track --path rust/ --root "${PREFIX}"

cd rust
maturin build --interpreter "${PYTHON}" --release --strip -b pyo3

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
