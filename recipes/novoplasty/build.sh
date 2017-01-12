#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak "s/\/usr\/bin\/perl/\/usr\/bin\/env perl/" NOVOPlasty${PKG_VERSION}.pl

chmod +x NOVOPlasty${PKG_VERSION}.pl
mv *.pl $PREFIX/bin
ln -s $PREFIX/bin/NOVOPlasty${PKG_VERSION}.pl $PREFIX/bin/novoplasty.pl

