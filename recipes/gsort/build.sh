#!/bin/bash

export CGO_ENABLED=0
export GOPATH="${PWD}"
export GOCACHE="${PWD}/.cache"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd cmd/gsort

go build

cp -f gsort_* $PREFIX/bin/gsort
chmod 0755 $PREFIX/bin/gsort
