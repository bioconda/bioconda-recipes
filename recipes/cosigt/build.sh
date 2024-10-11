#!/bin/bash

mkdir -p $PREFIX/bin
go mod init cosigt
go mod tidy
go get -d ./...
CGO_ENABLED=0 go build cosigt -o $PREFIX/bin/cosigt .
