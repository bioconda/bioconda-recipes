#!/bin/bash

git clone --recursive https://github.com/nanoporetech/pyspoa.git
cd pyspoa
git checkout v0.0.3
make build
$PYTHON -m pip install . --no-deps --ignore-install -vv
