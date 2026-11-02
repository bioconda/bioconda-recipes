#!/usr/bin/env bash
# build.sh for sam-subsampler — Rust crate with a native C dep (rust-htslib →
# hts-sys). rust-htslib 1.0.1 hardcodes `features = ["bindgen"]` on hts-sys,
# which produces opaque struct bindings under conda's cross-compile sysroot
# (the sysroot lacks standard C headers). Same workaround as cs-tagger: vendor
# all deps, drop the bindgen feature so hts-sys uses its pre-built bindings,
# fix the type mismatches in those pre-built bindings, refresh checksums.
#
# Patches verified against rust-htslib 1.0.1 + hts-sys 2.2.0:
#   - rust-htslib/Cargo.toml still has `features = ["bindgen"]`
#   - linux_prebuilt_bindings.rs still has `pub type size_t = c_ulong`,
#     `pub isize:` (keyword as field name), and `stringify!(isize)`
#   - rust-htslib 1.0.1 accesses the field as `core.isize_` (bam/record.rs)
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Let bindgen find libclang at build time.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# Cargo.toml is at the archive root (rattler-build flattens the single top-level
# folder into $SRC_DIR), so --path . and no `cd`. Vendor deps so we can patch them.
mkdir -p .cargo
cargo vendor vendor/ > .cargo/config.toml

# Drop the forced bindgen feature so hts-sys falls back to its pre-built bindings.
sed -i 's/features = \["bindgen"\]/features = []/' \
    vendor/rust-htslib/Cargo.toml

# Fix type mismatches in the pre-built bindings (bindgen output vs what
# rust-htslib expects):
# 1. size_t should be usize (not c_ulong/u64) to match rust-htslib usage.
# 2. `isize` is a Rust keyword and cannot be a field name; rust-htslib accesses
#    it as `isize_`, so rename the field and its #[derive] stringify!() site.
BINDINGS=vendor/hts-sys/linux_prebuilt_bindings.rs
sed -i 's/pub type size_t = ::std::os::raw::c_ulong;/pub type size_t = usize;/' "$BINDINGS"
sed -i 's/pub isize:/pub isize_:/' "$BINDINGS"
sed -i 's/stringify!(isize)/stringify!(isize_)/' "$BINDINGS"

# Refresh checksums for every patched file (cargo verifies vendored integrity).
for f in vendor/rust-htslib/Cargo.toml "$BINDINGS"; do
    sha=$(sha256sum "$f" | cut -d' ' -f1)
    base=$(basename "$f")
    dir=$(dirname "$f")
    sed -i "s|\"${base}\":\"[a-f0-9]*\"|\"${base}\":\"${sha}\"|" \
        "${dir}/.cargo-checksum.json"
done

# Build from the vendored tree. Versions are pinned by `cargo vendor`, so the
# shipped Cargo.lock is honored without --locked.
cargo install --no-track --root "$PREFIX" --path .

# Bundle third-party licenses (listed under about.license_file).
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
