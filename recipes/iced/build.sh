#!/bin/bash

set -xe

find . -type f -name *_.c -exec rm -f {} \;
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
