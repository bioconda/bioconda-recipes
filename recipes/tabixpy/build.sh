#!/bin/bash

# Do not include tests.
cat >MANIFEST.in <<"EOF"
recursive-include tabixpy README.md LICENSE.txt VERSION *.py
recursive-exclude tabixpy/tests *
graft examples
EOF

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
