#!/bin/bash
mkdir -p $PREFIX/bin

go get -d -v ./...
go test -v ./...
go build -o groot

mv groot $PREFIX/bin
