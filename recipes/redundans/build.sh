#!/bin/bash
export CPATH=${PREFIX}/include
#Define the install folder and binary folder and create them
INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER && mkdir -p $BIN_FOLDER

##NOTE: Cleanup this line after is fixed in next release
sed -i 's|0.14a|2.0.0|g' redundans.py

#Copying files to proper installation folder
chmod u+x redundans.py #To avoid permission issues
cp redundans.py $INSTALL_FOLDER/ && cp redundans.py $BIN_FOLDER && cp -r bin/SSPACE $BIN_FOLDER && cp README.md $INSTALL_FOLDER/
cp -r test/ $INSTALL_FOLDER/ && cp -r test/ $BIN_FOLDER && cp -r docs/ $INSTALL_FOLDER/ && cp LICENSE $INSTALL_FOLDER/

#We create a bin folder in the installation folder
mkdir -p $INSTALL_FOLDER/bin && cd $INSTALL_FOLDER/bin

#Download the missing binaries into bin. NOTE: find a way to include it in next release without interfering with git submodules
##First download some of the binary files and the python scripts
wget -O- http://platanus.bio.titech.ac.jp/?ddownload=145 > platanus && chmod +x platanus
curl -L https://github.com/attractivechaos/k8/releases/download/v0.2.4/k8-0.2.4.tar.bz2 | tar -jxf - && mv -t . ./k8-0.2.4/k8-Linux && rm -r ./k8-0.2.4/ 2>&1
wget -O- https://github.com/Gabaldonlab/redundans/archive/v2.00.tar.gz | tar -xz --strip-components=2 --wildcards '*/bin/*.py'
wget -O- https://github.com/Gabaldonlab/redundans/archive/v2.00.tar.gz | tar -xz --strip-components=2 --wildcards '*/bin/GapCloser'


##NOTE: till a new release adress this, keep the sed commands to solve the path issues
sed -i 's|bin/minimap2/misc/paftools.js|paftools.js|g' fasta2homozygous.py
sed -i 's|bin/minimap2/misc/paftools.js|paftools.js|g' fasta2scaffold.py
sed -i 's|bin/SSPACE/SSPACE_Standard_v3.0.pl|SSPACE/SSPACE_Standard_v3.0.pl|g' $BIN_FOLDER/redundans.py

#Download and make the LASTal and the merqury folder
wget -O- https://github.com/marbl/merqury/archive/v1.3.tar.gz && tar -zxvf v1.3.tar.gz && mv merqury-1.3 merqury
git clone https://github.com/Gabaldonlab/last.git
cd last/ && make clean && make -j && cd ..

#Cleaning up and copying from install folder to binary folder
rm redundans.py && cp -r * $BIN_FOLDER

##Added lastal compiled scripts to binary path
cp -t $BIN_FOLDER $INSTALL_FOLDER/bin/last/bin/*

##Gave permissions to test folder in order to run tests if required
chmod -R 777 $BIN_FOLDER/test/ && cd ..
