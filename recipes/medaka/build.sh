#!/bin/bash

# disable Makefile driven build of htslib.a
sed -i.bak 's/.*build_ext.*//' setup.py

# just link to htslib
sed -i.bak 's/extra_objects.*//' build.py
sed -i.bak 's/^libraries=\[/libraries=\["hts",/' build.py

$PYTHON -m pip install . --no-deps --ignore-installed -vv
