#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make 
make install
