#!/bin/bash -euo

RUST_BACKTRACE=1 C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install --verbose --root $PREFIX --path .
