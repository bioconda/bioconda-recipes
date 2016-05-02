#!/usr/bin/env bash

make cloneLib
make
make install INSTALLDIR=$PREFIX
