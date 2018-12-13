#!/bin/bash
mkdir -p $PREFIX/bin
mkdir groot
mv cmd src main.go groot/
mkdir -p src/github.com/will-rowe/
mv groot src/github.com/will-rowe/
cd src/github.com/will-rowe/groot

export GOPATH="$SRC_DIR/"
go get ./...
go build -o groot main.go
mv groot $PREFIX/bin
