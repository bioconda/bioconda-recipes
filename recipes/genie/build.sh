#!/bin/bash

ls -al
go build -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
