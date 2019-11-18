#!/bin/bash
set -eu -o pipefail
wget https://patch-diff.githubusercontent.com/raw/bulik/ldsc/pull/176.patch 
patch -p1 < 176.patch
$PYTHON -m pip install . --no-deps --ignore-installed -vv
