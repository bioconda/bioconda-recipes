#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps

# Load the CARD database JSON file
python `which rgi` load -i card-data/card.json
rm -rf card-data
