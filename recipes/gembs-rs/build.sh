#!/usr/bin/env bash

set -xe

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
