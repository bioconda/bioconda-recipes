#!/bin/bash

mkdir -p $PREFIX/bin

cp orthofinder.py $PREFIX/bin/orthofinder

# scripts_of now contains the config.json file
mkdir $PREFIX/bin/scripts_of
cp -r scripts_of/*py $PREFIX/bin/scripts_of/

sed -i.bak 's/raxmlHPC-AVX/raxmlHPC-AVX2/g' scripts_of/config.json
cp scripts_of/config.json $PREFIX/bin/scripts_of/config.json

cp tools/convert_orthofinder_tree_ids.py $PREFIX/bin/
cp tools/make_ultrametric.py $PREFIX/bin/
cp tools/primary_transcript.py $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder
chmod a+x $PREFIX/bin/convert_orthofinder_tree_ids.py
chmod a+x $PREFIX/bin/make_ultrametric.py
chmod a+x $PREFIX/bin/primary_transcript.py
