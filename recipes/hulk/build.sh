#!/bin/bash
mkdir -p $PREFIX/bin
mkdir hulk
mv cmd src main.go hulk/
mkdir -p src/github.com/will-rowe/
mv hulk src/github.com/will-rowe/
cd src/github.com/will-rowe/hulk

export GOPATH="$SRC_DIR/"
go get ./...
go build -o hulk main.go
mv hulk $PREFIX/bin
