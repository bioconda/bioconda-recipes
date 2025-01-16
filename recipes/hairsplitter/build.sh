#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin

mkdir src/build
cd src/build/
cmake ..
make -j ${CPU_COUNT}

cp ../../hairsplitter.py $PREFIX/bin
chmod +x $PREFIX/bin/hairsplitter.py
cp -r ./HS_call_variants $PREFIX/bin
cp -r ./HS_create_new_contigs $PREFIX/bin
cp -r ./HS_fa2gfa $PREFIX/bin
cp -r ./HS_gfa2fa $PREFIX/bin
cp -r ./HS_separate_reads $PREFIX/bin
cp -r ./HS_GenomeTailor/HS_GenomeTailor $PREFIX/bin
cp -r ../cut_gfa.py $PREFIX/bin
chmod +x $PREFIX/bin/cut_gfa.py

cp -r ../GraphUnzip/graphunzip.py $PREFIX/bin
chmod +x $PREFIX/bin/graphunzip.py
cp -r ../GraphUnzip/segment.py $PREFIX/bin
cp -r ../GraphUnzip/finish_untangling.py $PREFIX/bin
cp -r ../GraphUnzip/simple_unzip.py $PREFIX/bin
cp -r ../GraphUnzip/repolish.py $PREFIX/bin
cp -r ../GraphUnzip/transform_gfa.py $PREFIX/bin
cp -r ../GraphUnzip/input_output.py $PREFIX/bin
cp -r ../GraphUnzip/determine_multiplicity.py $PREFIX/bin
cp -r ../GraphUnzip/solve_with_long_reads.py $PREFIX/bin
cp -r ../GraphUnzip/solve_with_HiC.py $PREFIX/bin
cp -r ../GraphUnzip/contig_DBG.py $PREFIX/bin
chmod +x $PREFIX/bin/determine_multiplicity.py

