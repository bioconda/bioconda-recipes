#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak "s|!/usr/bin/perl||" NOVOPlasty${PKG_VERSION}.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g'  NOVOPlasty${PKG_VERSION}.pl

mv *.pl  $PREFIX/bin

chmod +x $PREFIX/bin/NOVOPlasty${PKG_VERSION}.pl
ln -s $PREFIX/bin/NOVOPlasty${PKG_VERSION}.pl $PREFIX/bin/NOVOPlasty.pl
