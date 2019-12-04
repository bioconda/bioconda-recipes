#!/bin/bash

go version
mkdir -p src/github.com/sakkayaphab/bolt
rsync -av --progress * src/github.com/sakkayaphab/bolt --exclude src
cd src/github.com/sakkayaphab/bolt
export GOPATH="$SRC_DIR/"
go get ./...
go build -o genie main.go 
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
