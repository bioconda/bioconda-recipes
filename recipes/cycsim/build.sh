#!/bin/bash -exuo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
export CMAKE_POLICY_VERSION_MINIMUM=3.5

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

if [ ! -f Cargo.lock ]; then
    cargo generate-lockfile
fi

cargo fetch --locked --verbose
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release --locked --verbose
cargo install --path . --root "${PREFIX}" --locked --verbose


rm -rf "${CARGO_HOME}"


