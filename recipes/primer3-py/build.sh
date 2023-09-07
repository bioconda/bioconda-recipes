#!/bin/bash

sed -i.bak '/^CC /d' primer3/src/libprimer3/Makefile
python -m pip install . -vv
