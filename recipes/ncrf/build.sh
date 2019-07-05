#!/bin/sh

mkdir -p $PREFIX/bin

make 

chmod +x NCRF

mv NCRF $PREFIX/bin

chmod +x *.py
cp *.py $PREFIX/bin/
ln -s $PREFIX/bin/ncrf_to_bed.py $PREFIX/bin/ncrf_to_bed
ln -s $PREFIX/bin/ncrf_summary.py $PREFIX/bin/ncrf_summary
ln -s $PREFIX/bin/ncrf_sort.py $PREFIX/bin/ncrf_sort
ln -s $PREFIX/bin/ncrf_cat.py $PREFIX/bin/ncrf_cat
ln -s $PREFIX/bin/ncrf_resolve_overlaps.py $PREFIX/bin/ncrf_resolve_overlaps
ln -s $PREFIX/bin/ncrf_consensus_filter.py $PREFIX/bin/ncrf_consensus_filter
