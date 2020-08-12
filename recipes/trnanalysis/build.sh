#!/bin/bash

# remove install_requires (no longer required with conda package)
sed -i'' -e '/REPO_REQUIREMENT/,/pass/d' setup.py
sed -i'' -e '/# dependencies/,/dependency_links=dependency_links,/d' setup.py

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

