#!/bin/bash

mkdir -p $PREFIX/bin

find . -name "*.py" | xargs -I {} mv {} $PREFIX/bin
chmod a+x ${PREFIX}/bin/*.py
