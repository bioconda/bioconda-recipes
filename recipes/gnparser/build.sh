#!/bin/bash

set -xe

cd gnparser
CGO_ENABLED=0
go clean
go build .
mkdir -p $PREFIX/bin
mv gnparser $PREFIX/bin
