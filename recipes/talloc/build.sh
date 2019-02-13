#!/bin/bash

python2 buildtools/bin/waf configure --prefix=$PREFIX
make
make install
