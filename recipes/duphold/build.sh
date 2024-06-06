#!/bin/bash
set -xeu -o pipefail

pushd hts-nim
nimble install -y --verbose
popd

pushd genoiser
nimble install -y --verbose
popd

nimble install -y --verbose

mkdir -p "${PREFIX}/bin"
mv duphold "${PREFIX}/bin/"
