#!/bin/sh
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX
make
make install prefix=$PREFIX
