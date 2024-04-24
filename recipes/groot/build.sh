#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

go get -d -v ./...
# tests are disabled due to a problem with a test dependency:
# gopath/pkg/mod/github.com/dgryski/go-minhash@v0.0.0-20190315135803-ad340ca03076/minwise_test.go:6:2: no required module provides package github.com/dgryski/go-metro; to add it:[0m
# go test -v ./...
go build -o groot

mv groot $PREFIX/bin
