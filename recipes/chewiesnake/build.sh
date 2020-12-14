#!/bin/bash

mkdir -p $PREFIX/bin

cp chewieSnake.py $PREFIX/bin/chewiesnake

cp chewieSnake_join.py $PREFIX/bin/chewiesnake_join

cp -r scripts/* $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*.sh $PREFIX/bin/*.R $PREFIX/bin/*.py

