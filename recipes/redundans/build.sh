#!/bin/bash
export CPATH=${PREFIX}/include
#Define the install folder and binary folder and create them
INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER && mkdir -p $BIN_FOLDER

#Copying files to proper installation folder
chmod u+x redundans.py #To avoid permission issues

#Avoid pathing issues with SSPACE pl script
sed -i.bak 's|bin/SSPACE/SSPACE_Standard_v3.0.pl|SSPACE/SSPACE_Standard_v3.0.pl|g' redundans.py

###### Copying files to proper installation directory and some to the binary directory ######
cp redundans.py $INSTALL_FOLDER/ && cp redundans.py $BIN_FOLDER && cp README.md $INSTALL_FOLDER/
cp -r test/ $INSTALL_FOLDER/ && cp -r test/ $BIN_FOLDER && cp -r docs/ $INSTALL_FOLDER/ && cp LICENSE $INSTALL_FOLDER/

#We create a bin folder in the installation directory where we copy all binaries and scripts
mkdir -p $INSTALL_FOLDER/bin &&  cp -r bin/SSPACE $INSTALL_FOLDER/bin && cp bin/*.py $INSTALL_FOLDER/bin && cp bin/k8-Linux $INSTALL_FOLDER/bin
cp bin/platanus $INSTALL_FOLDER/bin && cp bin/GapCloser $INSTALL_FOLDER/bin && cp -r bin/last $INSTALL_FOLDER/bin && cp -r bin/merqury $INSTALL_FOLDER/bin

#Cleaning up and copying from install folder to binary folder
cp -r $INSTALL_FOLDER/bin/* $BIN_FOLDER/

#Compile last and copy its binaries to BIN_FOLDER
cd $BIN_FOLDER/last/ && make clean && make -j ${CPU_COUNT} && cd ..
cp -t $BIN_FOLDER $BIN_FOLDER/last/bin/*

#Give permissions to test folder in order to run tests if required
chmod -R 777 $BIN_FOLDER/test/ && cd ..
