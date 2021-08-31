#!/bin/bash

sed 's/__version__ = "2.0.3"/__version__ = "2.0.4.2"/' idr/__init__.py > t
mv t idr/__init__.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
