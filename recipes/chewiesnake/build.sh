#!/bin/bash

mkdir -p $PREFIX/bin

cp chewieSnake.py $PREFIX/bin/chewiesnake

cp chewieSnake_join.py $PREFIX/bin/chewiesnake_join

cp scripts/*.py *.R *.sh $PREFIX/bin/

cp scripts/common/__init__.py $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*.sh $PREFIX/bin/*.R $PREFIX/bin/*.py

