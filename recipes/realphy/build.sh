#!/bin/bash

mkdir -p $PREFIX/bin
cp * $PREFIX/bin
ln -s $PREFIX/bin/REALPHY_v113 $PREFIX/bin/realphy
