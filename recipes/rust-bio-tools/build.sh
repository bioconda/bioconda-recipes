#!/bin/bash -e
export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --root $PREFIX
