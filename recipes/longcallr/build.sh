#!/bin/bash
set -euo pipefail

# Install Rust binary
cargo install --locked --path . --root "$PREFIX"
rm -rf "$PREFIX/.crates*"

# Install Python scripts to $PREFIX/bin
install -m 755 allele_specific/longcallR-asj.py "$PREFIX/bin/longcallR-asj"
install -m 755 allele_specific/longcallR-ase.py "$PREFIX/bin/longcallR-ase"
install -m 755 allele_specific/asj_to_bed.py "$PREFIX/bin/asj_to_bed"
