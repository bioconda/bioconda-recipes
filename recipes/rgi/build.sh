#!/bin/bash

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir

# Load the CARD database JSON file
python $PREFIX/bin/rgi load -i card-data/card.json
rm -rf card-data

# Makesure blast/diamond database is built
mkdir -p rgi-temp
cd rgi-temp
wget --quiet --output-document=homolog.fasta https://raw.githubusercontent.com/arpcard/rgi/master/tests/inputs/homolog.fasta
python $PREFIX/bin/rgi main -i homolog.fasta -o output --debug -a diamond --clean
cd ..
rm -rf rgi-temp
