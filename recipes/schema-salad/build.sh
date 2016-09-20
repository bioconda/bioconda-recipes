#!/bin/bash

sed -i.bak 's/ruamel.yaml ==/ruamel.yaml >=/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
