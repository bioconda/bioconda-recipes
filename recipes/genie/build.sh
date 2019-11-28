#!/bin/bash

ls -al
go version
pwd
mkdir -p src/github.com/sakkayaphab/bolt
mv bed cli fasta gff hts variant vcf main.go go.sum go.mod vendor src/github.com/sakkayaphab/bolt
cd src/github.com/sakkayaphab/bolt
pwd
ls -al
export GOPATH="$SRC_DIR/"
go build -o genie main.go 
ls -al
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
