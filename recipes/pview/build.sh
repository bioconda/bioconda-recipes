#! /bin/bash
cd src
if [ `uname` == Darwin ]; then
    qmake -nocache -spec macx-g++
else
    qmake -nocache
fi
make
cp pview $PREFIX/bin
chmod +x $PREFIX/bin/pview