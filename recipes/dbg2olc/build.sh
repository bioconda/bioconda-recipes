#!/usr/bin/env bash

wget -c https://raw.githubusercontent.com/yechengxi/DBG2OLC/master/compiled/AssemblyStatistics
wget -c https://raw.githubusercontent.com/yechengxi/DBG2OLC/master/compiled/SelectLongestReads
mkdir -p $PREFIX/bin/
mv * $PREFIX/bin/
