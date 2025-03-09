#!/usr/bin/env bash

set -xe

go mod tidy
go build -o allhic -v cmd/main.go

mkdir -p ${PREFIX}/bin
install -m 755 allhic ${PREFIX}/bin
