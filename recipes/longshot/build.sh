#!/bin/bash
set -ex

# this build script is taken from the rust-bio-tools recipe
# https://github.com/bioconda/bioconda-recipes/blob/master/recipes/rust-bio-tools/build.sh

# taken from yacrd recipe, see: https://github.com/bioconda/bioconda-recipes/blob/2b02c3db6400499d910bc5f297d23cb20c9db4f8/recipes/yacrd/build.sh
if [ "$(uname)" == "Darwin" ]; then
    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    echo $HOME
    #export HOME="/Users/distiller"
    export HOME=~/
    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    git config --global --unset url.ssh://git@github.com.insteadOf
fi

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --path . --root $PREFIX
