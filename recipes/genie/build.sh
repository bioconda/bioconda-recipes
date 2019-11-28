#!/bin/bash

cd genie-0.4.1
go build -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
