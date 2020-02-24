#!/bin/bash
mkdir -p $PREFIX/bin

#export GOPATH="$SRC_DIR/"
rm go.mod

go get github.com/pierrec/lz4 && cd $GOPATH/src/github.com/pierrec/lz4 && git fetch && git checkout v3.0.1
cd $SRC_DIR

go get -d -t -v ./...
go test -v ./...
ls -l
#go build -o groot main.go
go build -v ./...
mv groot $PREFIX/bin
