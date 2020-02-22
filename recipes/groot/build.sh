#!/bin/bash
mkdir -p $PREFIX/bin

#export GOPATH="$SRC_DIR/"
rm go.mod
go get -d -t -v ./...
go test -v ./...
ls -l
#go build -o groot main.go
go build -v ./...
mv groot $PREFIX/bin
