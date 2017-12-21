#!/bin/bash

mkdir -p $PREFIX/bin

cd orthofinder/

cp orthofinder.py $PREFIX/bin/orthofinder

cp config.json $PREFIX/bin/

cp -r scripts $PREFIX/bin/

# The following script is not yet in 2.1.2 release, see https://github.com/davidemms/OrthoFinder/issues/125
#cp -r tools/convert_tree_ids.py $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder
