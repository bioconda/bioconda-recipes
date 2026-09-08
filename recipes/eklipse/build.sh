#!/bin/bash

sed -i 's/from collections import namedtuple, Iterable/from collections import namedtuple\nfrom collections.abc import Iterable/' tabulate.py
sed -i 's/from itertools import zip_longest as izip_longest/from itertools import zip_longest/' tabulate.py

chmod +x eKLIPse.py
sed -i '1s|.*|#!/usr/bin/env python\n&|' eKLIPse.py
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/data
mkdir -p ${PREFIX}/bin/doc
cp -r data/* ${PREFIX}/bin/data/
cp -r doc/* ${PREFIX}/bin/doc/
cp -r *py  ${PREFIX}/bin/
