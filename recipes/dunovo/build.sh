#!/bin/bash

make
mv *.so $PREFIX/lib
mv *.awk *.sh *.py utils/outconv.py $PREFIX/bin
