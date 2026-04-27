#!/bin/bash -e

set -x

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

set +x
