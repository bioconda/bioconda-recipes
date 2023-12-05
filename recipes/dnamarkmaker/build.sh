#! /bin/bash

python -m pip install --no-deps --ignore-installed .

c_dir=$(pwd)
cd $PREFIX/lib/python*/site-packages/dnamarkmaker
o_dir=$(pwd)
mkdir dnamarkmaker
cd ${c_dir}
cp dnamarkmaker/primer_recipe.txt ${o_dir}/dnamarkmaker
cp dnamarkmaker/sim_Aa_95.txt ${o_dir}/dnamarkmaker
