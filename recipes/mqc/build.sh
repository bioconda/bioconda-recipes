#! /bin/bash

cp mQC.pl $PREFIX/bin
chmod +x $PREFIX/bin/mQC.pl
mkdir $PREFIX/bin/mqc_tools
cp mqc_tools/*.py $PREFIX/bin/mqc_tools
chmod +x $PREFIX/bin/mqc_tools/*.py
cp mqc_tools/*.R $PREFIX/bin/mqc_tools
chmod +x $PREFIX/bin/mqc_tools/*.R
