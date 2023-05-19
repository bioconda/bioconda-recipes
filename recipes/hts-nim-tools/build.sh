#!/bin/bash
set -eu -o pipefail

pushd hts-nim
nimble install -y
popd

nimble install -y

chmod +x hts_nim_tools
mkdir -p "${PREFIX}/bin"
cp hts_nim_tools "${PREFIX}/bin/"
