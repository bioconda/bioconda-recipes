#!/bin/bash
make
mkdir -p $PREFIX/bin
cp IntervalStats $PREFIX/bin
chmod +x $PREFIX/bin/IntervalStats
