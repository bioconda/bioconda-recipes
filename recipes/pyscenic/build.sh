#!/bin/bash
set -e
echo "Current working directory: $(pwd)"
echo "Listing files in working directory:"
ls -l
echo "Applying patch..."
patch -p1 < ${RECIPE_DIR}/dill_patch.patch

echo "Patch applied, listing files:"
ls -l
$PYTHON -m pip install . --no-deps --ignore-installed -vv
