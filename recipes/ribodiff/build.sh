#!/bin/bash

$PYTHON setup.py install

cp scripts/TE.py $PREFIX/bin
chmod +x $PREFIX/bin