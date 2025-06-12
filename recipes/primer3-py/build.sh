#!/bin/bash

sed -i.bak '/^CC /d' primer3/src/libprimer3/Makefile
$PYTHON -m pip install . --use-pep517 --no-deps --no-build-isolation -vvv
