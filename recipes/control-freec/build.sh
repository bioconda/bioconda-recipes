#!/bin/bash

cd src
make

mkdir -p $PREFIX/bin
cp freec $PREFIX/bin
