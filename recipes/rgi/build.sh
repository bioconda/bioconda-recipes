#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD database JSON file
python $PREFIX/bin/rgi load -i card-data/card.json
rm -rf card-data

# Run rgi main once to build the necessary DB files
mkdir temp-rgi
cd temp-rgi
wget --quiet --output-document=homolog.fasta https://raw.githubusercontent.com/arpcard/rgi/master/tests/inputs/homolog.fasta 
python $PREFIX/bin/rgi main -i homolog.fasta -o output --debug -a diamond --clean
cd ..
rm -rf temp-rgi
