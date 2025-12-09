#!/bin/bash

set -eu -o pipefail

$PYTHON -m pip install . --no-deps --no-build-isolation -vvv
