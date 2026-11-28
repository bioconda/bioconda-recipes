#!/bin/bash
set -euo pipefail

# Keep cargo's registry inside the build tree (conda-build cleans it up).
export CARGO_HOME="${SRC_DIR}/.cargo-home"

# 1. Licences of every dependency, for the package's licence files.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# 2. The static binary.
cargo install --no-track --locked --root "$PREFIX" --path crates/gloci

# 3. Man pages, from the clap definition.
mkdir -p "$PREFIX/share/man/man1"
cargo run --locked -p xtask -- man --out "$PREFIX/share/man/man1"

# 4. Shell completions, from the same definition.
assets="$SRC_DIR/target/assets/completions"
cargo run --locked -p xtask -- completions --out "$assets"
mkdir -p "$PREFIX/share/bash-completion/completions" \
         "$PREFIX/share/zsh/site-functions" \
         "$PREFIX/share/fish/vendor_completions.d"
install -m 0644 "$assets/gloci.bash" "$PREFIX/share/bash-completion/completions/gloci"
install -m 0644 "$assets/_gloci" "$PREFIX/share/zsh/site-functions/_gloci"
install -m 0644 "$assets/gloci.fish" "$PREFIX/share/fish/vendor_completions.d/gloci.fish"
