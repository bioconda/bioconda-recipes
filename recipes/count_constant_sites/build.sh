#!/bin/bash
if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

cargo build --release
mv target/release/count_constant_sites $PREFIX/bin
