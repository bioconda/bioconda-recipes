#!/bin/env bash

./configure --with-libpotrace --prefix=$PREFIX
make
make install

