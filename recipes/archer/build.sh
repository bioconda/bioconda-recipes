#!/bin/bash

mkdir -p $PREFIX/bin
go get -d -v ./...
CGO_ENABLED=0 go build -o $PREFIX/bin/archer .
