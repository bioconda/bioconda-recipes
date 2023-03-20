#!/bin/bash

# change path so viralflye can find itself
sed -i '/#entry point/a print(os.getcwd())' viralFlye.py
sed -i '/#entry point/a os.chdir(viralflye_root)' viralFlye.py

cp -r viralflye $PREFIX/opt/
cp viralFlye.py $PREFIX/opt/
ln -s $PREFIX/opt/viralFlye.py $PREFIX/bin/viralFlye.py
