#!/bin/bash
cd qpms9
make
cp Release/qpms9 $PREFIX/bin
chmod +x $PREFIX/bin/qpms9

cd ../qpms9-data
make
cp Release/qpms9-data $PREFIX/bin
chmod +x $PREFIX/bin/qpms9-data