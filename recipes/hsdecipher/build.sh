#!/bin/bash

mkdir -p $PREFIX/bin

cp HSD_heatmap.py $PREFIX/bin/hsd_heatmap

cp HSD_add_on.py $PREFIX/bin/HSD_add_on.py
cp HSD_batch_run.py $PREFIX/bin/HSD_batch_run.py
cp HSD_categories.py $PREFIX/bin/HSD_categories.py
cp ko.tsv $PREFIX/bin/ko.tsv

chmod a+x $PREFIX/bin/hsd_heatmap
chmod a+x $PREFIX/bin/HSD_add_on.py
chmod a+x $PREFIX/bin/HSD_batch_run.py
chmod a+x $PREFIX/bin/HSD_categories.py

