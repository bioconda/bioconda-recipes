#!/bin/bash

ls -al
go version
pwd
mkdir -p src/github.com/sakkayaphab/bolt
mv bed cli fasta gff hts variant vcf main.go go.sum go.mod vendor src/github.com/sakkayaphab/bolt
cd src/github.com/sakkayaphab/bolt
pwd
export GOPATH="$SRC_DIR/"
GO111MODULE=on go build main.go -o genie
ls -al
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
