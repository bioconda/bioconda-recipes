#!/bin/bash
set -eu -o pipefail

pushd hts-nim
nimble install -y
popd

nimble install -y

chmod +x nimnexus
mkdir -p "${PREFIX}/bin"
cp nimnexus "${PREFIX}/bin/"
