#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w qcli/ scripts/*
	$PYTHON setup.py install	
else
	$PYTHON setup.py install
fi
