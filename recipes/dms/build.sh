#!/bin/bash
mkdir -p ${PREFIX}/bin
chmod u+x install.sh
./install.sh

export DynamicMetaStorms=${PREFIX}/
export PATH=\$PATH:\$DynamicMetaStorms/bin

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
