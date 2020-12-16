#!/bin/bash

mkdir -p $PREFIX/bin

cp chewieSnake.py $PREFIX/bin/chewiesnake

cp chewieSnake_join.py $PREFIX/bin/chewiesnake_join

cp scripts/*.py scripts/*.R scripts/*.sh scripts/common/*.py $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*.sh $PREFIX/bin/*.R $PREFIX/bin/*.py $PREFIX/bin/chewiesnake $PREFIX/bin/chewiesnake_join

