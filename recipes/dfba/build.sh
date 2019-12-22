#!/usr/bin/env bash

set -eux

unset MACOSX_DEPLOYMENT_TARGET

echo $(pwd)
${PYTHON} -m pip install .;
