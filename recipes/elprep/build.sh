#!/bin/bash

export CGO_ENABLED=0
export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export GOPATH="$PREFIX"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

go install
