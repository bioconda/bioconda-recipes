#!/bin/bash

# Keep track of the process
set -uex

mkdir -p $PREFIX/bin
mv * $PREFIX/bin
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"

# Needs to run in the install folder
cd ${PREFIX}/bin

sh install.sh

# clean up
rm -rf eutils cmd help   
rm -rf *.log *.go *.yaml setup.sh install.sh *.gz *.pdf 
rm -rf idx-* index-*  pm-*  custom* xy-* CA.pm cacert.pem
