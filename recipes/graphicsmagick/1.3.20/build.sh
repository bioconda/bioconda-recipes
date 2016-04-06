#!/bin/env bash

./configure --prefix=$PREFIX --enable-shared=yes
make
make install
