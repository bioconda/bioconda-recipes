#!/usr/bin/env bash

set -eu

#if [ `uname` == Darwin ]; then
#  export HOME=`mktemp -d`
#fi

cargo build --release

mv target/release/fq "${PREFIX}/bin"
