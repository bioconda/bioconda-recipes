#!/bin/bash

# Install both the pairix binaries and the Python extension module
make
cp bin/pairix $PREFIX/bin/pairix
cp bin/pairs_merger $PREFIX/pairs_merger
cp bin/streamer_1d $PREFIX/streamer_1d
$PYTHON setup.py install 
