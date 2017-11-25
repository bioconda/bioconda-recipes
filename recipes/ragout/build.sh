#!/bin/bash
make
$PYTHON scripts/install-sibelia.py --prefix $PREFIX
cp ragout.py $PREFIX/bin/
cp -r ragout $PREFIX/bin/
