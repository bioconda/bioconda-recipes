#!/bin/bash
chmod +x eKLIPse.py
sed -i '1s|.*|#!/usr/bin/env python2\n&|' eKLIPse.py
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/data
mkdir -p ${PREFIX}/bin/doc
cp -r data/* ${PREFIX}/bin/data/
cp -r doc/* ${PREFIX}/bin/doc/
cp -r *py  ${PREFIX}/bin/
