#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .

python_path=$PREFIX/lib/R/library/DEXSeq/python_scripts
echo python3 ${python_path}/dexseq_prepare_annotation.py '"$@"' > $PREFIX/bin/dexseq_prepare_annotation.py
chmod +x $PREFIX/bin/dexseq_prepare_annotation.py

echo python3 ${python_path}/dexseq_count.py '"$@"' > $PREFIX/bin/dexseq_count.py
chmod +x $PREFIX/bin/dexseq_count.py
