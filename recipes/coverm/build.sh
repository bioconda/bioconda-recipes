#!/bin/bash -e

# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
cargo build --release

# Install the binary
mkdir -p ${PREFIX}/bin
cp target/release/coverm $PREFIX/bin

# Install the shell completion script
mkdir -p ${PREFIX}/share/bash-completion/completions
target/release/coverm shell-completion --shell bash --output-file $PREFIX/share/bash-completion/completions/coverm