#!/bin/bash

mkdir -p ${PREFIX}/bin
export PATH=${PREFIX}/bin
export DynamicMetaStorms=${PREFIX}

chmod u+x install.sh
./install.sh

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
