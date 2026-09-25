#!/bin/bash -e

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
