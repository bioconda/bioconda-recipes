#!/bin/bash

export GOPATH="$SRC_DIR/"
go build -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
