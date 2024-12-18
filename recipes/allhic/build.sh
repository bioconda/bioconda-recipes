#!/usr/bin/env bash

set -xe

# we need go.mod because we use a modern Go compiler and allhic v0.9.13 does not have it yet
wget https://raw.githubusercontent.com/tanghaibao/allhic/e495b41169fe4d9e3285a959a4ce5a0003cc210f/go.mod
wget https://raw.githubusercontent.com/tanghaibao/allhic/e495b41169fe4d9e3285a959a4ce5a0003cc210f/go.sum

go get -v -t ./...
go build -o allhic -v cmd/main.go

mkdir -p ${PREFIX}/bin
install -m 755 allhic ${PREFIX}/bin
