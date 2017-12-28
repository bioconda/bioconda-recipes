#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX} --with-libmuscle=${PREFIX}/include/libMUSCLE-3.7/
make 
make install
ls -Srthl src/*
ls -Srthl bin/*

cp -R * ${PREFIX}/bin/parsnp_folder/

cp src/parsnp ${PREFIX}/bin/
cp Parsnp.py ${PREFIX}/bin/
cp template.ini ${PREFIX}/bin/


if [ "$(uname)" == "Darwin" ]; then
    cp bin/harvest_osx ${PREFIX}/bin/harvest
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cp bin/harvest_linux ${PREFIX}/bin/harvest
fi


ln -s ${PREFIX}/bin/fasttree ${PREFIX}/bin/ft
ln -s ${PREFIX}/bin/Phi ${PREFIX}/bin/phiprofile


