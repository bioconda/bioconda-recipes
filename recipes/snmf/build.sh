 #!/bin/bash

snmf=$PREFIX/opt/snmf
mkdir -p $snmf
chmod 777 $snmf
cp -r * $snmf/
cp -r $RECIPE_DIR/* $snmf/
bash $snmf/install.command
chmod +x $snmf/snmf.sh
chmod +x $snmf/plink
chmod +x $snmf/Snmf.pl
cp -r $snmf/* $PREFIX/bin
