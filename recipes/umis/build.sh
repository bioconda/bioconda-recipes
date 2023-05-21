#!/bin/bash
if [ `uname` == Darwin ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.9
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
