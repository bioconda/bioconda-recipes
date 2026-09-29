#!/bin/bash

mkdir -p $PREFIX/bin

cp BINge.py $PREFIX/bin/BINge.py
ln -s $PREFIX/bin/BINge.py $PREFIX/bin/BINge
cp BINge_post.py $PREFIX/bin/BINge_post.py
ln -s $PREFIX/bin/BINge_post.py $PREFIX/bin/BINge_post
cp _version.py $PREFIX/bin/_version.py

mkdir -p $PREFIX/bin/modules
cp -r modules/* $PREFIX/bin/modules/

mkdir -p $PREFIX/bin/tests
cp -r tests/* $PREFIX/bin/tests/

mkdir -p $PREFIX/bin/utilities
cp -r utilities/* $PREFIX/bin/utilities/

chmod a+x $PREFIX/bin/BINge
chmod a+x $PREFIX/bin/BINge_post
