#!/bin/bash

mkdir -p $PREFIX/bin
chmod 755 smn_caller.py
chmod 755 smn_charts.py
cp -r ./* $PREFIX/bin/
