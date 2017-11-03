#!/bin/bash
mkdir -p $PREFIX/bin

cp src/py/* $PREFIX/bin
export VALET=$PREFIX/bin
