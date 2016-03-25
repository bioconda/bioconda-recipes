#!/bin/bash

cd sdk/cwl
sed -i.bak -e '/cmdclass=/s/^/#/' setup.py
sed -i.bak "s/version='1.0'/version='$PKG_VERSION'/" setup.py
$PYTHON setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
