#!/usr/bin/env bash

set -xe

go get -v -t ./...
go build -o allhic -v cmd/main.go

mkdir -p ${PREFIX}/bin
install -m 755 allhic ${PREFIX}/bin
