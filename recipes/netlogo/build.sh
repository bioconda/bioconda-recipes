#!/bin/bash

BINARY_HOME=$PREFIX/bin
NETLOGO_HOME=$PREFIX/share/netlogo

mkdir -p $PREFIX/bin
mkdir -p $NETLOGO_HOME

#sed -i "s|APP_HOME=.*|APP_HOME=\"${PACKAGE_HOME}\"|g" nf-test

cp -r * $NETLOGO_HOME/

cp $RECIPE_DIR/netlogo-headless.sh $NETLOGO_HOME/

chmod +x $NETLOGO_HOME/netlogo-headless.sh 

ln -s $NETLOGO_HOME/netlogo-headless.sh  $PREFIX/bin/netlogo-headless.sh 

