#!/bin/bash

./configure --prefix=$PREFIX
make LIBS+=-lhts
make install
