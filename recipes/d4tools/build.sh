#!/bin/bash -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export PKG_CONFIG_ALLOW_CROSS=1
export HTSLIB=system
export RUSTFLAGS="${RUSTFLAGS:-} -L${PREFIX}/lib"

if [ ! -f "${PREFIX}/lib/pkgconfig/bzip2.pc" ]; then
cat > "${PREFIX}/lib/pkgconfig/bzip2.pc" <<PCEOF
prefix=${PREFIX}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: bzip2 compression library
Version: 1.0.8
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
PCEOF
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cp -f ${RECIPE_DIR}/build_htslib.sh d4-hts/build_htslib.sh

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path d4tools --root "${PREFIX}"
