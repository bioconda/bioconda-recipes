#!/bin/bash
target=$PREFIX/lib/kraken
mkdir -p $target
bash install_kraken.sh $target/bin
mkdir -p $PREFIX/bin
ln -s $target/bin/kraken* $PREFIX/bin
