#!/bin/bash
pwd
ls -l
./autogen.sh
./configure --prefix=$PREFIX
make
make install
