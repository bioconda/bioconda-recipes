#!/bin/bash

autoreconf --install
./configure --prefix=$PREFIX
make install
