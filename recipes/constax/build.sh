#!/bin/bash

mkdir -p $PREFIX/bin

constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $constax
cp -r ./* $constax


echo "export SINTAXPATH=vsearch" > $constax/pathfile.txt
echo "Installing RDP ..."
git clone https://github.com/rdpstaff/RDPTools.git > /dev/null 2>&1
cd RDPTools
git submodule init AlignmentTools ReadSeq classifier TaxonomyTree > /dev/null 2>&1
git submodule update > /dev/null 2>&1
sed -i 's/1.5/1.6/' AlignmentTools/nbproject/project.properties ReadSeq/nbproject/project.properties classifier/nbproject/project.properties
sed -i 's/basedir="."/basedir="." xmlns:unless="ant:unless"/' classifier/build.xml
sed -i 's/name="download-traindata" unless="offline"/name="download-traindata" unless="skip_td_download"/' classifier/build.xml
sed -i 's+move file="${dist.dir}/data.tgz"+move unless:set="skip_td_download" file="${dist.dir}/data.tgz"+' classifier/build.xml
rm AlignmentTools/parseErrorAnalysis.py
cd classifier
ant jar -Dskip_td_download=true > /dev/null 2>&1
echo "export RDPPATH=$constax/RDPTools/classifier/dist/classifier.jar" >> $constax/pathfile.txt
cd ../..
echo "RDP installed ..."

echo "export CONSTAXPATH=$constax" >> $constax/pathfile.txt
cp -r ./* $constax
chmod +x $constax/constax.sh

mkdir -p $PREFIX/bin
ln -s $constax/constax.sh $PREFIX/bin/constax.sh
