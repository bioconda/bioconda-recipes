#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
make CC="$CC $LDFLAGS" CFLAGS="$CFLAGS"
cp biscuit $BIN
cp QC.sh $BIN
cp build_biscuit_QC_assets.pl $BIN
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $BIN/build_biscuit_QC_assets.pl
