#!/bin/bash

go get -u github.com/fatih/color
go get -u github.com/fiam/gounidecode/unidecode
go get -u github.com/klauspost/cpuid
go get -u github.com/pbnjay/memory
go get -u github.com/surgebase/porter2
go get -u golang.org/x/text/runes
go get -u golang.org/x/text/transform
go get -u golang.org/x/text/unicode/norm

ls -l
go build -o xtract xtract.go common.go
go build -o rchive rchive.go common.go
ls -l

mv * "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/setup.sh

