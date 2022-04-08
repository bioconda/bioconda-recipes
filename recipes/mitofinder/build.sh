#!/usr/bin/env python

./install.sh

mkdir -p ${PREFIX}/bin/

cp *.py ${PREFIX}/bin/
cp mitofinder ${PREFIX}/bin/
cp ./arwen/arwen ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/arwen
chmod +x ${PREFIX}/bin/mitofinder
