#!/usr/bin/env bash

set -xe

export CGO_ENABLED=0
export GOCACHE=$PWD/.cache/
export LDFLAGS=(
    "-s"
    "-w"
    "-X main.version=${PKG_VERSION}"
)

mkdir -p $GOCACHE
mkdir -p ${PREFIX}/bin

go mod tidy
go build -ldflags "$(echo -n ${LDFLAGS[@]})" -o ${PKG_NAME}

install -m 755 ${PKG_NAME} ${PREFIX}/bin
