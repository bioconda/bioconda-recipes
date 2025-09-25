#!/bin/bash
set -xe

mkdir -p ${PREFIX}/bin

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
$PYTHON -m pip install git+https://github.com/gtonkinhill/panaroo
