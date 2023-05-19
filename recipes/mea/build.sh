#!/bin/bash

## Configure and make
./configure --prefix=$PREFIX
make -j

## Install
make install
