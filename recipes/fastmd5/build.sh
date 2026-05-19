#!/bin/bash
set -exuo pipefail

export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CARGO_HOME=$(pwd)/.cargo
export CARGO_TARGET_DIR=$(pwd)/target

if [[ "$(uname)" == "Darwin" ]]; then
  export CFLAGS="${CFLAGS:-} -O3"
  export CXXFLAGS="${CXXFLAGS:-} -O3"
else
  export CFLAGS="${CFLAGS:-} -O3 -Wno-implicit-function-declaration"
  export CXXFLAGS="${CXXFLAGS:-} -O3"
fi

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

cargo install --locked --path . --root "${PREFIX}"
