#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak "s/\/usr\/bin\/perl/\/usr\/bin\/env perl/" NOVOPlasty${PKG_VERSION}.pl
tail -n+2 NOVOPlasty${PKG_VERSION}.pl > NOVOPlasty${PKG_VERSION}.pl.new

mv NOVOPlasty${PKG_VERSION}.pl.new NOVOPlasty${PKG_VERSION}.pl 
ln -s NOVOPlasty${PKG_VERSION}.pl novoplasty.pl
chmod +x NOVOPlasty${PKG_VERSION}.pl
chmod +x novoplasty.pl

mv *.pl $PREFIX/bin
