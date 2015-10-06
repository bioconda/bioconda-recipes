#!/bin/sh
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX
make -j
make -j -- install prefix=$PREFIX
