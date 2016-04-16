#!/bin/sh

export CPATH=${PREFIX}/include
make install prefix=$PREFIX
