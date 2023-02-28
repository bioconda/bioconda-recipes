#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p src/github.com/jteutenberg/downpore

mv commands consensus data img mapping model overlap seeds sequence trim util downpore.go  src/github.com/jteutenberg/downpore
cd src/github.com/jteutenberg/downpore

export GOPATH="$SRC_DIR/"

go build downpore.go
mv downpore $PREFIX/bin
