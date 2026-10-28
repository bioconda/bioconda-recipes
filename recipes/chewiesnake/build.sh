#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/chewiesnake/

cp -r * $PREFIX/opt/chewiesnake/

ln -s $PREFIX/opt/chewiesnake/scripts/Clustering_DistanceMatrix.R $PREFIX/opt/chewiesnake/scripts/alleleprofile_hasher.py $PREFIX/opt/chewiesnake/scripts/hashID.py $PREFIX/opt/chewiesnake/scripts/create_alleledbSheet.sh $PREFIX/opt/chewiesnake/scripts/create_sampleSheet.sh $PREFIX/bin/

ln -s $PREFIX/opt/chewiesnake/chewieSnake.py $PREFIX/bin/chewiesnake

ln -s $PREFIX/opt/chewiesnake/chewieSnake_join.py $PREFIX/bin/chewiesnake_join

chmod -R u+x $PREFIX/bin/*

