#!/bin/bash

sed -i.bak ' s| = muscle| = |g' libMUSCLE/Makefile.am

sh autogen.sh
./configure --prefix=$PREFIX
make
make install
