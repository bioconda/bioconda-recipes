#!/bin/bash

mkdir -p $PREFIX/bin
go mod tidy
go get -d ./...
CGO_ENABLED=0 go build -o $PREFIX/bin/archer .
