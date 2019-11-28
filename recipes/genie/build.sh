#!/bin/bash

ls -al
go version
pwd
# mkdir -p src/github.com/sakkayaphab/bolt
# cp -r * src/github.com/sakkayaphab/bolt
# cd src/github.com/sakkayaphab/bolt
# pwd
go build main.go -o genie
ls -al
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
