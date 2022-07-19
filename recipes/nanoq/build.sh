#!/bin/bash
set -ex

# adopted from: https://github.com/bioconda/bioconda-recipes/blob/master/recipes/rasusa/build.sh 

RUST_BACKTRACE=full

if [ "$(uname)" == "Darwin" ]; then
    # apparently the HOME variable isn't set correctly, and circle ci 
    # output indicates the following as the home directory
    export HOME="/Users/distiller"
    export HOME=`pwd`
    echo "HOME is $HOME"

    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 
    # removing circle ci default configuration solves cargo trouble downloading crates
    # git config --global --unset url.ssh://git@github.com.insteadOf
fi

cargo install -v --locked --root "$PREFIX" --path .