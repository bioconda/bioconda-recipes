#!/bin/bash

./configure --prefix=$PREFIX --without-x
make
make install

