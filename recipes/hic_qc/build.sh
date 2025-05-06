#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

export VERSION=1.2.913c977

git tag $VERSION
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
