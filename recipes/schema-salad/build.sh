#!/bin/bash

#sed -i.bak 's/ruamel.yaml ==/ruamel.yaml >=/' setup.py
sed -i.bak 's/ruamel.yaml >= 0.12.4, < 0.12.5/ruamel.yaml >= 0.12.4/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
