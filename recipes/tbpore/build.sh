#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

rm poetry.lock
poetry config experimental.new-installer false
poetry install  # regenerates poetry.lock
cat poetry.lock  # outputs contents so we know what we are installing in bioconda machine
