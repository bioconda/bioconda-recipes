#!/bin/bash

chmod u+x install.sh
./install.sh
cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
