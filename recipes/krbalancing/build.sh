#!/bin/bash
sed -i.bak  "s#-std=c++11#-std=c++11\", \"-I$BUILD_PREFIX/lib/clang/8.0.0/include#" setup.py
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
