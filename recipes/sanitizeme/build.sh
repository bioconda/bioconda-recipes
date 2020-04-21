#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/test
chmod 0755 *.py
cp *.py ${PREFIX}/bin/
cp test/* ${PREFIX}/test/

