#!/bin/bash
chmod +x eKLIPse.py
sed -i '1s|.*|#!/usr/bin/env python2\n&|' eKLIPse.py
mkdir -p ${PREFIX}/bin
cp -r data/* doc/* *py  ${PREFIX}/bin/
