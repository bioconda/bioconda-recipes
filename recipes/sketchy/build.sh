#!/bin/bash
set -x
export RUST_BACKTRACE=full

if [ "$(uname)" == "Darwin" ]; then
    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    export HOME="/Users/distiller"
    echo "HOME is $HOME"
    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    # git config --global --unset url.ssh://git@github.com/.insteadOf

    # https://github.com/rust-lang/cargo/issues/1851#issuecomment-288791836
    # printf 'Host *\n  UseKeychain yes\n  AddKeysToAgent yes\n  IdentityFile ~/.ssh/id_rsa\n' >> "${HOME}/.ssh/config"
    # ssh-add -K "${HOME}/.ssh/id_rsa"

    printf "[net]\ngit-fetch-with-cli = true\n" >> ~/.cargo/config
fi

cargo install -v --locked --root "$PREFIX" --path .

"$PYTHON" -m pip install --no-deps --ignore-installed -vv .
