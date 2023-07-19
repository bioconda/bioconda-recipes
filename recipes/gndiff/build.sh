#!/bin/bash

cd gndiff
go build
mkdir -p $PREFIX/bin
mv gndiff $PREFIX/bin
