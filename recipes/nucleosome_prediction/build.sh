#!/usr/bin/bash

mkdir -p $PREFIX/lib
cp -R ./* $PREFIX/
cp $RECIPE_DIR/libstdc++* $PREFIX/lib/
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/*.pl
