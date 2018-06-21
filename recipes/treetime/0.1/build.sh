#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
mkdir -p $PREFIX/bin
echo -e "#!/usr/bin/env python\n" > $PREFIX/bin/ancestral_reconstruction.py
echo -e "#!/usr/bin/env python\n" > $PREFIX/bin/timetree_inference.py
cat ancestral_reconstruction.py >> $PREFIX/bin/ancestral_reconstruction.py
cat timetree_inference.py >>  $PREFIX/bin/timetree_inference.py
chmod a+x $PREFIX/bin/ancestral_reconstruction.py $PREFIX/bin/timetree_inference.py
