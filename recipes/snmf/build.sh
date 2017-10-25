 #!/bin/bash

snmf=$PREFIX/opt/snmf
mkdir -p $snmf
chmod 777 $snmf
cp -r * $snmf/
rm -rf bin
rm -rf code
cp -r $RECIPE_DIR/* $snmf/
chmod +x $snmf/snmf.sh
chmod +x $snmf/plink
chmod +x $snmf/Snmf.pl
cp -r $snmf/* $PREFIX/bin
