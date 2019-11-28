#!/bin/bash

rm -rf ~/go
go build -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
