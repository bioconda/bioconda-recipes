#!/bin/bash

make
mv *.so $PREFIX/lib
mv *.py *.sh $PREFIX/bin
