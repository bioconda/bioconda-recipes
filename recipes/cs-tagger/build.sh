#!/usr/bin/env bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Tell bindgen where to find libclang
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# The Cargo project lives in the nested cs-tagger/ directory of the source tree.
cd cs-tagger

# Vendor all dependencies locally so we can patch them.
mkdir -p .cargo
cargo vendor vendor/ > .cargo/config.toml

# rust-htslib 1.0.0 hardcodes features = ["bindgen"] on hts-sys in its
# [dependencies.hts-sys] section. This forces runtime bindgen which produces
# opaque struct bindings in conda's cross-compilation environment because
# the sysroot lacks standard C headers. Patch it out so hts-sys uses its
# pre-built bindings instead.
sed -i 's/features = \["bindgen"\]/features = []/' \
    vendor/rust-htslib/Cargo.toml

# Fix pre-built bindings type mismatches between bindgen output and
# what rust-htslib expects:
# 1. size_t should be usize (not c_ulong/u64) to match rust-htslib usage
# 2. bam1_core_t.isize should be isize_ to match rust-htslib field access
BINDINGS=vendor/hts-sys/linux_prebuilt_bindings.rs
sed -i 's/pub type size_t = ::std::os::raw::c_ulong;/pub type size_t = usize;/' "$BINDINGS"
sed -i 's/pub isize:/pub isize_:/' "$BINDINGS"
sed -i 's/stringify!(isize)/stringify!(isize_)/' "$BINDINGS"

# Update checksums for all patched files so cargo accepts the modified vendor tree.
for f in vendor/rust-htslib/Cargo.toml "$BINDINGS"; do
    sha=$(sha256sum "$f" | cut -d' ' -f1)
    base=$(basename "$f")
    dir=$(dirname "$f")
    sed -i "s|\"${base}\":\"[a-f0-9]*\"|\"${base}\":\"${sha}\"|" \
        "${dir}/.cargo-checksum.json"
done

# Build from vendored deps
cargo install --no-track --root "$PREFIX" --path .

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/cs-tagger/THIRDPARTY.yml"
