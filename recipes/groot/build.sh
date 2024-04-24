#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

go get -d -v ./...
GO111MODULE=off go test -v ./...
go build -o groot

mv groot $PREFIX/bin
