#!/usr/bin/env bash

set -eu

if [ "$(uname)" == "Darwin" ]; then
  export HOME=`mktemp -d`
fi

cargo build --release

mv target/release/kmer-counter "${PREFIX}/bin"
