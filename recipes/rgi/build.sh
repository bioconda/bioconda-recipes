#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

cd card-data

mv card.json ..

cd ..

./rgi database

./rgi load -i card.json

./rgi database

rm -rf card-data

ls

rgi
