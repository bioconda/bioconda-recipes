#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod 0755 *.py
cp -r * ${PREFIX}/bin/
