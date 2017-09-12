#!/bin/bash

sed -i.bak -E 's/setup_requires.+//' setup.py
sed -i.bak -E 's/install_requires.+//' setup.py
$PYTHON setup.py install
