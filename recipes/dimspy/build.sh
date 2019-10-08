#!/bin/bash

export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64

$PYTHON -m pip install . --no-deps --ignore-installed -vv
