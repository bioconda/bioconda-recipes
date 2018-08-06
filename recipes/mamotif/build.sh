#!/bin/bash

#The scripts have the wrong line endings!
for f in bin/* ;
do
    tr -d "\r" < $f > $f.new
    mv $f.new $f
    chmod a+x $f
done
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
