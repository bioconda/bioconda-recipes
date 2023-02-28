#!/bin/sh

mkdir -p $PREFIX/bin

sed -ie 's/\/usr\/bin\/perl/\/usr\/bin\/env perl/g' pal2nal.pl
cp pal2nal.pl $PREFIX/bin/pal2nal.pl

chmod a+x $PREFIX/bin/pal2nal.pl

pal2nal.pl -h
