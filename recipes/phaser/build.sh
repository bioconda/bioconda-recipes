#!/bin/bash

mkdir -p $PREFIX/bin/

cd phaser
python setup.py build_ext --inplace
chmod +x phaser.py
sed -i "1s/.*/\#!\/usr\/bin\/env python2/" phaser.py
cp phaser.py $PREFIX/bin/phaser.py

cd ..
sed -i '1 i\\#!\/usr\/bin\/env python2' phaser_annotate/phaser_annotate.py
chmod +x phaser_annotate/phaser_annotate.py
cp phaser_annotate/phaser_annotate.py ${PREFIX}/bin/

sed -i '1 i\\#!\/usr\/bin\/env python2' phaser_gene_ae/phaser_gene_ae.py
chmod +x phaser_gene_ae/phaser_gene_ae.py
cp phaser_gene_ae/phaser_gene_ae.py ${PREFIX}/bin/


