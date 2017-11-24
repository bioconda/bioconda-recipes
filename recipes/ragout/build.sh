#!/bin/bash
make
$PYTHON scripts/install-sibelia.py
cp ragout.py $PREFIX/bin/
cp -r ragout $PREFIX/bin/
