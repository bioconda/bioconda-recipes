#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

sed -i.bak "s|os.environ\['BASENJIDIR'\]|'${PREFIX}/share/basenji/'|g" bin/*.py 

cp bin/*.py $PREFIX/bin/

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
mkdir -p ${PREFIX}/lib/python${PYVER}/site-packages/
cp -r ./basenji ${PREFIX}/lib/python${PYVER}/site-packages/

mkdir -p $PREFIX/share/basenji
cp -r ./data ${PREFIX}/share/basenji/
