#!/bin/bash
set -xe

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --verbose --path . --root "${PREFIX}"
