#!/bin/bash

./configure --prefix=$PREFIX
make
make install

cd tests
make
