#!/bin/bash
mkdir -p $PREFIX/bin

#export GOPATH="$SRC_DIR/"
go get -d -t -v ./...
ls -l
#go build -o groot main.go
go build -v ./...
mv groot $PREFIX/bin
