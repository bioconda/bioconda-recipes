#!/bin/bash
sed -i.bak 's/==/>=/' requirements2.txt
sed -i.bak 's/==/>=/' requirements3.txt
$PYTHON setup.py install 
