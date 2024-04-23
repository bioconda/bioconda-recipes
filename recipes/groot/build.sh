#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

go get -d -v ./...

# for some reason some test dependencies cannot be resolved at CircleCI
if [ $(uname -m) != "aarch64" ]; then
go test -v ./...
fi

go build -o groot

mv groot $PREFIX/bin
