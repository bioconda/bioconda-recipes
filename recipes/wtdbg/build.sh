#!/bin/bash

mkdir -p "$PREFIX/bin"

make

cp * $PREFIX/bin 

