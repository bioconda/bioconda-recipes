#!/bin/bash

printenv > /project/maizegdb/sagnik/FINDER/whatsprefix
cd $SRC_DIR/src/olego/
make
cd ../../assemblies_psiclass_modified/
make
cd ../..
chmod -R a+x *
