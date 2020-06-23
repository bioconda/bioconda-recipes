#!/bin/bash

$PYTHON setup.py install


cp bin/NanoMod.py $PREFIX/bin/
chmod +x $PREFIX/bin/NanoMod.py

