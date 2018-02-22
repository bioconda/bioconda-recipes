#!/bin/bash -euo

unset REQUESTS_CA_BUNDLE ## TODO: remove these `unset` lines, once the following issue in `conda-build` is resolved:
unset SSL_CERT_FILE      ##       <https://github.com/conda/conda-build/issues/2255>

# build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib:/usr/lib64 cargo install --root $PREFIX --verbose --debug
