#!/bin/bash

mkdir -p $PREFIX/bin

cp HSDFinder.py $PREFIX/bin/hsdfinder

cp HSD_to_KEGG.py $PREFIX/bin/hsd_to_kegg
cp operation.py $PREFIX/bin/operation.py
cp pfam.py $PREFIX/bin/pfam.py
cp KO_database.keg $PREFIX/bin/KO_database.keg

#chmod a+x $PREFIX/bin/hsdfinder
#chmod a+x $PREFIX/bin/hsd_to_kegg
#chmod a+x $PREFIX/bin/operation.py
#chmod a+x $PREFIX/bin/pfam.py

