#!/bin/bash -xeuo
pushd packages/grz-check
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
