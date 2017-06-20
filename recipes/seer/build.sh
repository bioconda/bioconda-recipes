#!/bin/bash

cd ${PREFIX}/gzstream && make

make
make test
make install