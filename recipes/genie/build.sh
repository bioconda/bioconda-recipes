#!/bin/bash

ls -al
mkdir -p src/github.com/sakkayaphab/bolt
cp -r * src/github.com/sakkayaphab/bolt
cd src/github.com/sakkayaphab/bolt
go build main.go -o genie
ls -al
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
