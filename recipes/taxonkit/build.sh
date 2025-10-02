#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p $PREFIX/bin

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

cd taxonkit
go build -trimpath -o=${PREFIX}/bin/taxonkit -ldflags="-s -w" -tags netgo
