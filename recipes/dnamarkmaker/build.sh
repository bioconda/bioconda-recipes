#! /bin/bash


# mkdir -p $PREFIX/bin

# cp -R dnamarkmaker_txt $PREFIX/bin/
# cp -R dnamarkmaker_script $PREFIX/bin

# chmod +x $PREFIX/bin/*/*

python -m pip install --no-deps --ignore-installed .

# pip install primer3-py

c_dir=$(pwd)
cd $PREFIX/lib/python*/site-packages/dnamarkmaker
o_dir=$(pwd)
mkdir dnamarkmaker
cd ${c_dir}
cp dnamarkmaker/primer_recipe.txt ${o_dir}/dnamarkmaker
cp dnamarkmaker/sim_Aa_95.txt ${o_dir}/dnamarkmaker
