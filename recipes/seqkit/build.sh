#!/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd seqkit
go build -trimpath -o=${PREFIX}/bin/seqkit -ldflags="-extldflags '-static' -s -w" -tags netgo
