#!/bin/bash

mkdir -p $PREFIX/bin/

cd phaser
python setup.py build_ext --inplace
chmod +x phaser.py
sed -i.bak "1s|.*|#!/usr/bin/env python2|" phaser.py
cp phaser.py $PREFIX/bin/phaser.py

cd ..
sed -i.bak '1s|^|#!/usr/bin/env python2 \'$'\n|' phaser_annotate/phaser_annotate.py
chmod +x phaser_annotate/phaser_annotate.py
cp phaser_annotate/phaser_annotate.py ${PREFIX}/bin/

sed -i.bak '1s|^|#!/usr/bin/env python2 \'$'\n|' phaser_gene_ae/phaser_gene_ae.py
chmod +x phaser_gene_ae/phaser_gene_ae.py
cp phaser_gene_ae/phaser_gene_ae.py ${PREFIX}/bin/


