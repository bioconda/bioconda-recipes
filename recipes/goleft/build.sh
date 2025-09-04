#!/bin/bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

mkdir -p $PREFIX/bin

cd cmd/goleft

go build -o goleft goleft.go

install -v -m 0755 goleft* "$PREFIX/bin"
