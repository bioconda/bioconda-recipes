#!/bin/sh

./configure --prefix=$PREFIX CPPFLAGS=-DUNIXCONSOLE
make
make install
