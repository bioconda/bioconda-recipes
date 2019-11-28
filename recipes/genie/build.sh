#!/bin/bash

ls -al
go build main.go -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
