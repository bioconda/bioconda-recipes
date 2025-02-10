#!/bin/bash

mkdir -p $PREFIX/bin
cp genotyphi.py $PREFIX/bin/genotyphi.py
ln $PREFIX/bin/genotyphi.py $PREFIX/bin/genotyphi
chmod +x $PREFIX/bin/genotyphi.py $PREFIX/bin/genotyphi

# Add script for Mykrobe based analysis
wget -O parse_typhi_mykrobe.py https://raw.githubusercontent.com/typhoidgenomics/genotyphi/main/typhimykrobe/parse_typhi_mykrobe.py
echo "#! /usr/bin/env python" > $PREFIX/bin/parse_typhi_mykrobe.py
cat parse_typhi_mykrobe.py >> $PREFIX/bin/parse_typhi_mykrobe.py
chmod 755 $PREFIX/bin/parse_typhi_mykrobe.py
