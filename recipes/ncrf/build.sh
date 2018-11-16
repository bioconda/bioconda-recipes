#!/bin/sh

mkdir -p $PREFIX/bin

make 

chmod +x NCRF

mv NCRF $PREFIX/bin

chmod +x *.py
cp *.py $PREFIX/bin/
cp ncrf_to_bed.py $PREFIX/bin/ncrf_to_bed
cp ncrf_summary.py $PREFIX/bin/ncrf_summary
cp ncrf_sort.py $PREFIX/bin/ncrf_sort
cp ncrf_cat.py $PREFIX/bin/ncrf_cat
cp ncrf_resolve_overlaps.py $PREFIX/bin/ncrf_resolve_overlaps
cp ncrf_consensus_filter.py $PREFIX/bin/ncrf_consensus_filter
