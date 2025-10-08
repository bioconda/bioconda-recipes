#!/bin/bash

set -ex

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv

# https://github.com/nextgenusfs/funannotate/issues/1129
ROOT=$(python -c "from importlib.util import find_spec; print(find_spec('funannotate').submodule_search_locations.pop())")
chmod -R ugo+x $ROOT/aux_scripts
