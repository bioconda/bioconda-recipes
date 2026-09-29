#!/bin/bash -e

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --verbose --root "${PREFIX}" --path .
