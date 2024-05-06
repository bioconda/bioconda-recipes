#!/bin/bash

mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin
cp cami_amber/utils/add_length_column.py $PREFIX/bin
cp cami_amber/utils/convert_fasta_bins_to_biobox_format.py $PREFIX/bin

chmod +x $PREFIX/bin/*.py