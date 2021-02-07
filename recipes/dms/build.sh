#!/bin/bash
mkdir -p ${PREFIX}/bin
chmod u+x install.sh
./install.sh
cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
