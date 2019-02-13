#!/bin/bash
sed -i.bak 's/==/>=/' requirements.txt
$PYTHON setup.py install --single-version-externally-managed --root=/
