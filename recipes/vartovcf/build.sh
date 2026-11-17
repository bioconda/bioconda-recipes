#!/bin/bash -e

cargo-bundle-licenses --format yaml --output THIRD

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
