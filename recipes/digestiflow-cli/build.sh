#!/bin/bash -e

# circumvent a bug in conda-build >=2.1.18,<3.0.10
# https://github.com/conda/conda-build/issues/2255
[[ -z $REQUESTS_CA_BUNDLE && ${REQUESTS_CA_BUNDLE+x} ]] && unset REQUESTS_CA_BUNDLE
[[ -z $SSL_CERT_FILE && ${SSL_CERT_FILE+x} ]] && unset SSL_CERT_FILE

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --root $PREFIX
