#!/bin/bash
set -xe

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "$PREFIX/bin"

go get -d -v ./...
go get github.com/dgryski/go-metro
go get github.com/dgryski/go-spooky
go test -v ./...
go build -o groot

install -v -m 0755 groot "$PREFIX/bin"
