#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/chewiesnake/

#cp chewieSnake.py $PREFIX/bin/chewiesnake

#cp chewieSnake_join.py $PREFIX/bin/chewiesnake_join

#cp scripts/*.py scripts/*.R scripts/*.sh scripts/common/*.py $PREFIX/bin/

cp -r * $PREFIX/opt/chewiesnake/

#chmod -R u+x $PREFIX/bin/*.sh $PREFIX/bin/*.R $PREFIX/bin/*.py $PREFIX/bin/chewiesnake $PREFIX/bin/chewiesnake_join

ln -s $PREFIX/opt/chewiesnake/scripts/*.R $PREFIX/opt/chewiesnake/scripts/*.sh $PREFIX/opt/chewiesnake/scripts/*.py  $PREFIX/bin/

ln -s $PREFIX/opt/chewiesnake/chewieSnake.py $PREFIX/bin/chewiesnake

ln -s $PREFIX/opt/chewiesnake/chewieSnake_join.py $PREFIX/bin/chewiesnake_join

chmod -R u+x $PREFIX/bin/*
