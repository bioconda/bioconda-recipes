#!/bin/bash
set -e  
patch -p1 < ${RECIPE_DIR}/dill_patch.patch

$PYTHON -m pip install . --no-deps --ignore-installed -vv
