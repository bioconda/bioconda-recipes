#!/bin/bash

fseq=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $fseq
cp -r ./* $fseq
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $fseq/mapviewToBed.pl
cp $RECIPE_DIR/fseq.py $fseq/bin/fseq
chmod +x $fseq/bin/fseq
chmod +x $fseq/mapviewToBed.pl
ln -s $fseq/bin/fseq $PREFIX/bin/fseq
ln -s $fseq/mapviewToBed.pl $PREFIX/bin/mapviewToBed.pl
