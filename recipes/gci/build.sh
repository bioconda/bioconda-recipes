#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin

sed -i.bak '1s|^|#!/usr/bin/env python\n\n|' GCI.py

chmod +x GCI.py
cp GCI.py ${PREFIX}/bin/gci