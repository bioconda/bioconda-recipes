#!/bin/bash

export PATH="$PATH:$PREFIX"

./configure --prefix=$PREFIX
make all
make install
