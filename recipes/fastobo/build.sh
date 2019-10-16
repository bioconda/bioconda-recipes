#!/bin/bash -e
# build script taken from `rust-bio-tools/build.sh`

# taken from yacrd recipe, see: https://github.com/bioconda/bioconda-recipes/blob/2b02c3db6400499d910bc5f297d23cb20c9db4f8/recipes/yacrd/build.sh
if [ "$(uname)" == "Darwin" ]; then

    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    export HOME="/Users/distiller"

    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    git config --global --unset url.ssh://git@github.com.insteadOf
fi

# install latest Rust nigthly compiler
export RUSTUP_HOME="$HOME/rustup"
export CARGO_HOME="$HOME/cargo"
wget https://sh.rustup.rs -O rustup.sh
sh rustup.sh -y --default-toolchain nightly
export PATH="$CARGO_HOME/bin:$PATH"

# build statically linked binary with Rust
RUSTFLAGS="-C linker=$CC" C_INCLUDE_PATH=$BUILD_PREFIX/include LIBRARY_PATH=$BUILD_PREFIX/lib $PYTHON -m pip install . --no-deps --ignore-installed -vv

# remove rustup and cargo
rm -rf "$RUSTUP_HOME"
rm -rf "$CARGO_HOME"
