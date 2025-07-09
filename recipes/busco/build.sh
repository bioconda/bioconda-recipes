#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

mkdir -p $PREFIX/bin/
cp bin/busco $PREFIX/bin/busco  #python script

