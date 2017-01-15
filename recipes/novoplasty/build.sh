#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak "s/\/usr\/bin\/perl/\/usr\/bin\/env perl/" NOVOPlasty${PKG_VERSION}.pl
tail -n+2 NOVOPlasty${PKG_VERSION}.pl > NOVOPlasty${PKG_VERSION}.pl.new

mv NOVOPlasty${PKG_VERSION}.pl.new NOVOPlasty.pl 
chmod +x NOVOPlasty.pl

mv *.pl $PREFIX/bin
