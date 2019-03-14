#!/bin/bash


env
if [ $PY3K -eq 3 ]
then
    for i in halla/*.py
    do
        2to3 --write $i
    done
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
