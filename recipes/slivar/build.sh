#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

VERSION="0.3.1"
PSLIVAR_SHA256SUM="4b103abacd83eb0b1c9082fd789f3f0eed78eb5d76710f037a1d3e1749d4f25e"

nimble --localdeps build -y --verbose -d:release

install -v -m 0755 slivar "${PREFIX}/bin"

curl -L -s -o pslivar https://github.com/brentp/slivar/releases/download/v${VERSION}/pslivar
sha256sum pslivar | grep ${PSLIVAR_SHA256SUM}

install -v -m 0755 pslivar "${PREFIX}/bin"
