#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX
make -j VERBOSE=1

# bug in qpdf, create empty files
touch doc/qpdf-manual.{pdf,html}

make install

