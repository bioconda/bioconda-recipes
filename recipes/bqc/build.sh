#!/bin/bash
set -xe

cd bqc

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --verbose --path . --root "${PREFIX}"
