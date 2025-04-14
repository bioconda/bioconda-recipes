#!/usr/bin/env bash
export CGO_ENABLED=0
export GOCACHE=$PWD/.cache/
export DATE=$(date -Iseconds)
export LDFLAGS=(
    "-s"
    "-w"
    "-X main.version=${PKG_VERSION}"
    "-X main.date=${DATE}"
)

mkdir -p $GOCACHE
mkdir -p $PREFIX/bin
# fix Go 1.18 build error on Mac
go get -u golang.org/x/sys 
# build
go build -ldflags "$(echo -n ${LDFLAGS[@]})" -o $PREFIX/bin/${PKG_NAME} ./cmd/${PKG_NAME} 
