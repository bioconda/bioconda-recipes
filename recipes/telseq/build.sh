#!/bin/bash

cd ./telseq-*/src
./autogen.sh
./configure
make
make install
