#!/bin/bash

make -C cpp CC=$CC CXX=$CXX
chmod 0755 cpp/msisensor-pro
cp -rf cpp/msisensor-pro $PREFIX/bin
