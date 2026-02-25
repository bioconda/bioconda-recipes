#!/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

go build -trimpath -o="${PREFIX}/bin/fqpack" -ldflags="-s -w -X main.version=v${PKG_VERSION}" -tags netgo ./cmd/fqpack
