#!/bin/bash

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)
tar -vxzf BamTable-*.tar.gz
cd BamTable-*/

make all
make install
