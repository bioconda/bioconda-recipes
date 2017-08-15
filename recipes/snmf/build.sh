 #!/bin/bash
snmf=$PREFIX/opt/snmf/
mkdir -p $snmf
mkdir -p $PREFIX/bin/
cp -rf ./*  $snmf/
cp $snmf/sNMF_CL_v1.2.zip .
unzip *.zip
cp -rf sNMF_CL_v1.2/* .
rm -rf sNMF_CL_v1.2/
chmod +x install.command
bash install.command
cp -rf ./* $snmf/
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $snmf/Snmf.pl
rm -f $snmf/Snmf.bak
chmod +x $snmf/snmf.sh
chmod +x $snmf/plink
chmod 777 $snmf/Snmf.pl
cp $snmf/snmf.sh $PREFIX/bin/
