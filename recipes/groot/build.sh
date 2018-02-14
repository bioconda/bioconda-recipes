#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p src/github.com/will-rowe/groot
mv cmd src main.go  src/github.com/will-rowe/groot
cd src/github.com/will-rowe/groot
export GOPATH="$SRC_DIR/"

go build -o groot main.go
mv groot $PREFIX/bin
