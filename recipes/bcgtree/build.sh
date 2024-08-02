#!/bin/sh
set -e

mkdir -pv "$PREFIX/bin" 
mkdir -pv "$PREFIX/SeqFilter"
mkdir -pv "$PREFIX/data"
mkdir -pv "$PREFIX/lib"

cp bin/* "$PREFIX/bin/"
cp -R SeqFilter/* "$PREFIX/SeqFilter/"
cp -R data/* "$PREFIX/data/"
cp -R lib/* "$PREFIX/lib"


