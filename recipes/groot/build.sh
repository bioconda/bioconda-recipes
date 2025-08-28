#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

go get -d -v ./...
go get github.com/dgryski/go-metro
go get github.com/dgryski/go-spooky
go test -v ./...
go build -o groot

mv groot $PREFIX/bin
