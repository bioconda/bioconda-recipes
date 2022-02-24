#!/bin/bash

if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

cp MiruHero $PREFIX/bin/
chmod +x $PREFIX/bin/MiruHero
