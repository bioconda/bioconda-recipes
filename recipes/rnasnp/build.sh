#!/bin/bash
./configure --prefix=$PREFIX
make
make install
cp -R lib/distParam $PREFIX/lib

#Add RNASNPPATH to the enviroment variables
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/rnasnp-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/rnasnp-deactivate.sh
## END BUILD
