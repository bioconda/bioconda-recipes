#!/bin/bash
set -o pipefail


# Make sure we use the environment's python and nothing else
sed -i.bak "1s@^.*\$@#!${PREFIX}/bin/python@" *.py

install -d "${PREFIX}/bin"
install -m 0755 *.py sectosupp "${PREFIX}/bin"
