#!/bin/bash

chmod +x calculate_statistics_orthograph_results.pl
mkdir -p $PREFIX/bin
cp $RECIPE_DIR/orthograph-* $RECIPE_DIR/*.pl $PREFIX/bin/
cp $RECIPE_DIR/orthograph.conf $PREFIX/bin/
cp -r $RECIPE_DIR/File $RECIPE_DIR/IO $RECIPE_DIR/Seqload $RECIPE_DIR/Wrapper $PREFIX/bin/
