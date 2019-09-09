#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Load the CARD database JSON file
python `which rgi` load -i card-data/card.json
rm -rf card-data
