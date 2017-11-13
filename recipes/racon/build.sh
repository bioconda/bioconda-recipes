#!/bin/bash

mkdir -p $PREFIX/bin

make -j

mv bin/racon $PREFIX/bin

