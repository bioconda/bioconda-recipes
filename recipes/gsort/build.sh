#!/bin/bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "$PREFIX/bin"

cd cmd/gsort/

go build ./gsort.go

install -v -m 0755 gsort "$PREFIX/bin"
