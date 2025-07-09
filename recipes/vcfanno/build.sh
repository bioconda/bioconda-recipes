#!/bin/bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

make all -j"${CPU_COUNT}"

install -v -m 0755 vcfanno* "${PREFIX}/bin"
