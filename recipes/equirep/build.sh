#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make
make install

