#!/bin/bash

mkdir -p $PREFIX/bin

cp chewieSnake.py $PREFIX/bin/chewiesnake

cp chewieSnake_join.py $PREFIX/bin/chewiesnake_join

cp scripts/* $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*

