#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd lexicmap
go build -trimpath -o=${PREFIX}/bin/lexicmap -ldflags="-extldflags '-static' -s -w" -tags netgo
