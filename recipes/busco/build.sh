#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

mkdir -p $PREFIX/bin/
install -m 0755 bin/busco $PREFIX/bin/busco  #python script

