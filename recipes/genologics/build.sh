#!/usr/bin/env bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
chmod -R o+r $PREFIX/lib/python*/site-packages/genologics*
