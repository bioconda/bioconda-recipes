#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
mkdir -p $PREFIX/bin
echo -e "#!/usr/bin/env python\n$(cat ancestral_reconstruction.py)" > ancestral_reconstruction.py
echo -e "#!/usr/bin/env python\n$(cat timetree_inference.py)" > timetree_inference.py
chmod a+x *.py
cp ancestral_reconstruction.py timetree_inference.py $PREFIX/bin
