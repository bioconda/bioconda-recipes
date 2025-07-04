#!/usr/bin/env bash

set -xe

mkdir -p "${PREFIX}/etc/"
cp -R \
  ./etc/css \
  ./etc/config_scripts \
  "${PREFIX}/etc/"

cd rust
cat > gemBS/Cargo.toml \
  gemBS/Cargo.toml.in \
  - << 'EOF'
default = ["slurm"]

[[bin]]
name = "gemBS"
path = "src/main.rs"
EOF

# LDFLAGS are not being passed through in rust/cargo's builds.
# TODO: Add these or similar changes to conda-forge/rust-activation-feedstock .
export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS}$(printf ' -C link-arg=%s' ${LDFLAGS})"

for tool in gemBS bs_call dbsnp_index mextr read_filter snpxtr ; do
  cargo install --no-track --locked --verbose --root "${PREFIX}" --path "${tool}"
done

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
