#!/bin/bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "$PREFIX/bin"

cd cmd/gsort/

sed -i.bak 's|0.1.4|0.1.5|' gsort.go
rm -f *.bak

go build ./gsort.go

install -v -m 0755 gsort "$PREFIX/bin"
