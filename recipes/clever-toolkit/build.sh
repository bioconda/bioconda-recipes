#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON .
make
make install
