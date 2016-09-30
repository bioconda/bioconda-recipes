#!/bin/bash

make
cp sam* $PREFIX/bin && \
cp libcansam.a $PREFIX/lib
cp -a cansam $PREFIX/include
