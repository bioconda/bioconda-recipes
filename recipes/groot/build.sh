#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

go get -d -v ./...
go test -v ./...
go build -o groot

mv groot $PREFIX/bin
