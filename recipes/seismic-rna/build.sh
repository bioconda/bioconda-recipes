#!/bin/bash

# DO NOT RUN THIS SCRIPT YOURSELF!
# It should only be run by conda build.

set -eux -o pipefail

$PYTHON -m pip install --no-dependencies $PWD