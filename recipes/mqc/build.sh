#! /bin/bash

mkdir -p $PREFIX/bin/mqc_tools
cp mQC.pl $PREFIX/bin
chmod +x $PREFIX/bin/mQC.pl
cp mqc_tools/*.py $PREFIX/bin/mqc_tools
chmod +x $PREFIX/bin/mqc_tools/*.py
cp mqc_tools/*.R $PREFIX/bin/mqc_tools
chmod +x $PREFIX/bin/mqc_tools/*.R
