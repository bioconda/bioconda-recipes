#!/bin/bash

cd gzstream && make

make
make test
make install