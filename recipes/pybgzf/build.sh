#!/bin/bash -e

export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
