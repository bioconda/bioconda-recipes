#!/bin/bash -e
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --root $PREFIX
