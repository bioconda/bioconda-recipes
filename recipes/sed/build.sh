#!/bin/bash
./bootstrap # This is needed only when the sed sources comes from the Git repo
./configure --prefix=$PREFIX
sed -i.bak -e 's/ -Wmissing-include-dirs//' Makefile
make
make install
