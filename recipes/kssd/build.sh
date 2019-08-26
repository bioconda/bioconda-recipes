#!/bin/bash
mkdir -p $PREFIX/bin/

make
cp kssd $PREFIX/bin/
