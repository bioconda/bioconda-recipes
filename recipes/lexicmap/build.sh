#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p $PREFIX/bin

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

cd lexicmap
go build -trimpath -o=${PREFIX}/bin/lexicmap -ldflags="-s -w" -tags netgo
