#!/bin/bash
set -exo pipefail

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir
install -m 755 bin/* "${PREFIX}/bin"
