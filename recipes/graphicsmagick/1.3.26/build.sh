#!/bin/env bash

./configure --prefix=$PREFIX --enable-shared --enable-symbol-prefix
make
make install
