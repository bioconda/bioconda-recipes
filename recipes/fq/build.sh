#!/usr/bin/env bash

set -eu

if [ "$(uname)" == "Darwin" ]; then
  export HOME=`mktemp -d`
fi

cargo install --verbose --locked --no-track --root "$PREFIX" --path .
