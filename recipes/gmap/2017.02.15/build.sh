#!/bin/sh
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX
make -j 2
make install prefix=$PREFIX
