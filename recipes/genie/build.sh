#!/bin/bash

go version
mkdir -p src/github.com/sakkayaphab/bolt
mv bed cli fasta gff hts variant vcf main.go go.sum go.mod vendor src/github.com/sakkayaphab/bolt
cd src/github.com/sakkayaphab/bolt
export GOPATH="$SRC_DIR/"
go get ./...
go build -o genie main.go 
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
