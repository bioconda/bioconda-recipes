#!/bin/bash
sed -i.bak 's/pyasn1-modules==0.0.5/pyasn1-modules>=0.0.5/' setup.py
$PYTHON setup.py install
