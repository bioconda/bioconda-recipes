#!/bin/bash

# This file is part of the Karate Club package.
git clone https://github.com/benedekrozemberczki/karateclub.git
cd karateclub
$PYTHON -m pip install . --no-build-isolation --no-cache-dir --no-deps --use-pep517 -vvv
cd ..
rm -rf karateclub

# Install the package using the setup.py script
$PYTHON setup.py install --single-version-externally-managed --record=$RECIPE_DIR/record.txt
