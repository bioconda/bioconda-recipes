#!/bin/bash

./prepare
./configure --prefix=$PREFIX
make && make install
