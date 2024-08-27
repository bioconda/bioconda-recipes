#!/bin/sh
set -e

mkdir -pv "$PREFIX/bin" 
mkdir -pv "$PREFIX/SeqFilter"
mkdir -pv "$PREFIX/data"
mkdir -pv "$PREFIX/lib"

sed -i 's/\/usr\/bin\/perl/\/bin\/env perl/' bin/*.pl
sed -i 's/\/usr\/bin\/python/\/bin\/env python/' bin/*.py
sed -i 's/\/bin\/bash/\/bin\/env bash/' bin/*.sh

cp bin/* "$PREFIX/bin/"
cp -R SeqFilter/* "$PREFIX/SeqFilter/"
cp -R data/* "$PREFIX/data/"
cp -R lib/* "$PREFIX/lib"


