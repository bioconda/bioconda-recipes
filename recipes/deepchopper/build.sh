#!/bin/bash

set -ex

maturin build --release --strip --manylinux 2014 --interpreter python
$PYTHON -m pip install . --no-deps -vv
