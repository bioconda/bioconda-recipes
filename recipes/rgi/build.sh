#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD database JSON file
python $PREFIX/bin/rgi load -i card-data/card.json
rm -rf card-data

# Run rgi main once to build the necessary DB files
mkdir temp-rgi
cd temp-rgi
python $PREFIX/bin/rgi main -i ${RECIPE_DIR}/tests/inputs/homolog.fasta -o output --debug -a diamond
cd ..
rm -rf temp-rgi
