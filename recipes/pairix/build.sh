#!/bin/bash

# Install both the pairix binaries and the Python extension module
make
cp bin/pairix $PREFIX/bin/pairix
cp bin/pairs_merger $PREFIX/bin/pairs_merger
cp bin/streamer_1d $PREFIX/bin/streamer_1d
$PYTHON setup.py install 
