#!/bin/bash
mkdir -p $PREFIX/bin

export GOPATH="$SRC_DIR/"
go get -d -t -v ./...
go build -o groot main.go
mv groot $PREFIX/bin
