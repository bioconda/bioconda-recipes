#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD databases
python $PREFIX/bin/rgi auto_load

# Makesure blast/diamond database is built
mkdir rgi-temp
cd rgi-temp
wget --quiet --output-document=homolog.fasta https://raw.githubusercontent.com/arpcard/rgi/master/tests/inputs/homolog.fasta
python $PREFIX/bin/rgi main -i homolog.fasta -o output --debug -a diamond --clean
cd ..
rm -rf rgi-temp
