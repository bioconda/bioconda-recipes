#!/bin/bash

chmod +x calculate_statistics_orthograph_results.pl
mkdir -p $PREFIX/bin
cp orthograph-* *.pl $PREFIX/bin/
cp orthograph.conf $PREFIX/bin/
cp -r File IO Seqload Wrapper $PREFIX/bin/
