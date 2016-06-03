#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w -n runBESST
        2to3 -w -n BESST
        2to3 -w -n setup.py
        2to3 -w -n scripts
	$PYTHON setup.py install	
else
	$PYTHON setup.py install
fi
