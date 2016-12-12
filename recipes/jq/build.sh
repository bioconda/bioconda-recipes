#!/bin/bash

./configure --prefix=${PREFIX} --disable-maintainer-mode
make
make install
