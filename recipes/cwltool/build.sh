#!/bin/bash
#sed -i.bak 's/schema_salad ==/schema_salad >=/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
