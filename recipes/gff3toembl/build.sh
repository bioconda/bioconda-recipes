#!/bin/bash


if [ "CONDA_PY" != "27" ]
then sed -i "s/urllib/urllib.parse/" gff3toembl/EMBLContig.py
fi

$PYTHON setup.py install


