#!/bin/bash

mkdir -p $PREFIX/bin

make

cp bin/TideHunter $PREFIX/bin
