#!/bin/bash

#cd sdk/cwl
sed -i.bak -e '/cmdclass=/s/^/#/' setup.py
sed -i.bak -e '/long_description=/s/^/#/' setup.py
sed -i.bak "s/version='1.0'/version='$PKG_VERSION'/" setup.py
$PYTHON setup.py install
