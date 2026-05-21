#!/bin/bash

set -euxo pipefail

# install mozaiko
$PYTHON -m pip install . --no-deps -vv

# install bundled CRABS
unzip external_scripts/crabs-0.1.7.zip

cd crabs-0.1.7

$PYTHON -m pip install . --no-deps -vv