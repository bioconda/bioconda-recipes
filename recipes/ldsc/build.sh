#!/bin/bash
set -eu -o pipefail
patch -p1 < $RECIPE_DIR/176.patch
$PYTHON -m pip install . --no-deps --ignore-installed -vv
