#!/bin/bash
tar xf gadem_v131targz.gz
cd GADEM_v1.3.1
./configure --prefix=$PREFIX 

ln -s gadem_documentation_v1.3.1.pdf doc/GADEM_documentation.pdf

make

make install
