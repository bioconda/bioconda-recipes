#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

cd card-data

mv card.json ..

cd ..

./rgi load -i card.json

rm -rf card-data
