#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD database JSON file
$PREFIX/bin/rgi load -i card-data/card.json
rm -rf card-data
