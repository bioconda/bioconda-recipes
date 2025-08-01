#!/bin/bash

export CGO_ENABLED=0
export GOPATH="${PWD}"
export GOCACHE="${PWD}/.cache"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd seqkit

go build

"${STRIP}" seqkit

install -v -m 0755 seqkit "${PREFIX}/bin"
