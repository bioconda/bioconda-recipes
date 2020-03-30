#!/bin/bash

mkdir -p $PREFIX/bin/config_files
mkdir -p $PREFIX/config_files

cp bin/* $PREFIX/bin
cp plasmidID $PREFIX/bin

cp config_files/* $PREFIX/bin/config_files

echo "INSTALING MASH 2"
echo "#############################################"

git clone https://github.com/marbl/Mash.git

cd Mash

./bootstrap.sh
./configure --with-capnp=$PREFIX --with-gsl=$PREFIX --prefix=$PREFIX
make
make install

echo "INSTALING CIRCOS WITH CUSTOM SETTINGS"
echo "#############################################"

wget http://circos.ca/distribution/circos-0.69-8.tgz
tar zxvf circos-0.69-8.tgz
cd circos-0.69-8
sed -i "s/max_points_per_track =.*/max_points_per_track = 80000000/g" etc/housekeeping.conf
cp -r . $PREFIX
