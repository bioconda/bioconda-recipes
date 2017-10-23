#!/bin/bash

sed -i.bak 's/bd2k-python-lib==/bd2k-python-lib>=/' setup.py
sed -i.bak 's/boto==/boto>=/' setup.py
$PYTHON setup.py install
