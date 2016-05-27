#!/bin/bash

sed -i.bak 's/bd2k-python-lib==/bd2k-python-lib>=/' setup.py
sed -i.bak 's/boto==/boto>=/' setup.py
$PYTHON setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
