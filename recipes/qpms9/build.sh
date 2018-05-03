#!/bin/bash
cd qpms9
make
cp Release/qpms9 $PREFIX/bin
chmod +x $PREFIX/bin/qpms9