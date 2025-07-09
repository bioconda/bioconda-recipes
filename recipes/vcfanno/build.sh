#!/bin/bash

export CGO_ENABLED=0
export GOPATH="${PWD}"
export GOCACHE="${PWD}/.cache"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

go mod download "github.com/BurntSushi/toml@v0.3.1"

make all -j"${CPU_COUNT}"

install -v -m 0755 vcfanno* "${PREFIX}/bin"
