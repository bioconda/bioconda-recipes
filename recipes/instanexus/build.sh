#!/bin/bash
set -euo pipefail

# Pure-python (noarch) install. --no-deps because every runtime dependency is
# pinned in meta.yaml's requirements/run; --no-build-isolation so the host
# environment's build backend is used. pip creates the `instanexus` console
# script from the package metadata.
$PYTHON -m pip install . --no-deps --no-build-isolation -vv
