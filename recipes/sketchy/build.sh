#!/bin/bash
set -x
export RUST_BACKTRACE=full

if [ "$(uname)" == "Darwin" ]; then
    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    export HOME="/Users/distiller"
    echo "HOME is $HOME"
    
    # Fix for when some packages use ssh to fetch git repos
    # See https://github.com/rust-lang/cargo/issues/1851#issuecomment-450130685
    mkdir -p "${HOME}/.cargo"
    printf "[net]\ngit-fetch-with-cli = true\n" >> "${HOME}/.cargo/config"
fi

cargo install -v --locked --root "$PREFIX" --path .

"$PYTHON" -m pip install --no-deps --ignore-installed -vv .
