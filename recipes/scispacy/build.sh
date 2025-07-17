#!/bin/bash

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -rf *.bak
{{ PYTHON }} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv