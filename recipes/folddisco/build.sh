#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

# Set C++ linking flags for macOS to ensure proper C++ standard library linking
if [[ "$OSTYPE" == "darwin"* ]]; then
	export RUSTFLAGS="-C link-arg=-L${PREFIX}/lib"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --features foldcomp --verbose --path . --root "${PREFIX}"
