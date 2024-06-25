#!/usr/bin/env bash

set -xe

mkdir -p "${PREFIX}/etc/"
cp -R \
  ./etc/css \
  ./etc/config_scripts \
  "${PREFIX}/etc/"

cd rust/gemBS
cat > Cargo.toml \
  Cargo.toml.in \
  - << 'EOF'
default = ["slurm"]

[[bin]]
name = "gemBS"
path = "src/main.rs"
EOF

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
