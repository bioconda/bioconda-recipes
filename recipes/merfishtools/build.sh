#!/bin/bash -e

# circumvent a bug in conda-build >=2.1.18,<3.0.10
# https://github.com/conda/conda-build/issues/2255
# TODO: remove once CI uses conda-build >=3.0.10
[[ -z $REQUESTS_CA_BUNDLE && ${REQUESTS_CA_BUNDLE+x} ]] && unset REQUESTS_CA_BUNDLE
[[ -z $SSL_CERT_FILE && ${SSL_CERT_FILE+x} ]] && unset SSL_CERT_FILE

# build statically linked binary with Rust
LIBRARY_PATH=$PREFIX/lib cargo build --release
# install the binary
cp target/release/merfishtools $PREFIX/bin
# install the Python package
$PYTHON setup.py install
