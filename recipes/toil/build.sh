#!/bin/bash

# For non-releases only: Avoid needing git/.git for version prep
#sed -i.bak 's/return _version()/return distVersion()/' version_template.py
#sed -i.bak 's/return _version(shorten=True)/return distVersion()/' version_template.py
#sed -i.bak 's/def currentCommit()/def _currentCommit()/' version_template.py
#sed -i.bak 's/def dirty()/def _dirty()/' version_template.py

$PYTHON -m pip install . --no-deps --ignore-installed -vv
