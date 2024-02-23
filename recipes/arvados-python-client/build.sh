#!/bin/bash
sed -i.bak 's/pyasn1-modules==0.0.5/pyasn1-modules>=0.0.5/' setup.py
sed -i.bak 's/google-api-python-client==/google-api-python-client>=/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
