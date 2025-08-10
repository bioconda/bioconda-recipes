#!/bin/bash

export CGO_ENABLED=0
export GOPATH="${PWD}"
export GOCACHE="${PWD}/.cache"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd cmd/smoove

go build

install -v -m 0755 smoove "$PREFIX/bin"
