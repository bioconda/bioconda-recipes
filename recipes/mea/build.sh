#!/bin/bash

## Configure and make
./configure
make -j${CPU_COUNT}

## Install
make install
