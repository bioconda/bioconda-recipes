#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
# We need gcc >= 4.9 and the Makevars are just getting ignored
if [[ $target_platform =~ linux.* ]] ; then
    foo=`which g++`
    rm $foo
    ln -s $GXX $foo
    ln -s ${PREFIX}/lib/libgfortran.so.3 ${PREFIX}/lib/libgfortran.so
    export LIBRARY_PATH=${PREFIX}/lib
fi
$R CMD INSTALL --build .
