#!/bin/bash -euo

set -xe

# Point htslib's build (via hts-sys) and bindgen at the conda prefix's headers and libraries.
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS:-} -O3 -Wno-deprecated-declarations"
# hts-sys uses bindgen to wrap htslib; make sure it sees the same include/lib flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

# Override the repo's .cargo/config.toml `-C target-cpu=native`, which would bake in the build
# host's CPU and SIGILL on older ones. The SIMD kernels are chosen at runtime, so nothing is lost.
export RUSTFLAGS=""
if [[ -n "${OSX_ARCH:-}" ]]; then
  export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# Bioconda requires the bundled third-party (vendored crate) licenses.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build and install only the binary crate. --locked pins the committed Cargo.lock.
RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --path crates/bwa-cli --root "${PREFIX}"
