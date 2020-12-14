#!/bin/bash

mkdir -p $PREFIX/bin

ln -s $PREFIX/chewieSnake.py $PREFIX/bin/chewiesnake

ln -s $PREFIX/chewieSnake_join.py $PREFIX/bin/chewiesnake_join

ln -s $PREFIX/scripts/ $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*

