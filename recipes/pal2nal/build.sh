#!/bin/sh

mkdir -p $PREFIX/bin

cp pal2nal.pl $PREFIX/bin/pal2nal.pl

chmod a+x $PREFIX/bin/pal2nal.pl

pal2nal.pl -h
