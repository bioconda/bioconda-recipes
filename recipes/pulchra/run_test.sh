#!/bin/bash
echo $PATH
ls -l $PREFIX/bin
if ! pulchra test/test-in.pdb ; then
    echo "pulchra ran, but returned $?"
fi
