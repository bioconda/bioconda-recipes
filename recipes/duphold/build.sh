#!/bin/bash
set -eu -o pipefail

nimble install -y hts@0.3.8
nimble install -y genoiser@0.2.7

nimble install -y --verbose

mkdir -p "${PREFIX}/bin"
mv duphold "${PREFIX}/bin/"
