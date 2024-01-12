#!/bin/bash
set -ex
./configure --prefix=$PREFIX 
ln -s gadem_documentation_v1.3.1.pdf doc/GADEM_documentation.pdf
make
make install
