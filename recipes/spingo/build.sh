#!/bin/sh

export CXX=${PREFIX}/bin/g++


cd source
if [ `uname` == Darwin ] ; then
    make
elif [ `uname` == Linux ] ; then ## linux    
    make boost-fix=1

else
    echo "Unknown OS system detected"
    exit
fi

mkdir -p $PREFIX/bin
cp spingo spindex $PREFIX/bin
cp ../dist/*.py $PREFIX/bin
chmod a+x $PREFIX/bin/*.py
