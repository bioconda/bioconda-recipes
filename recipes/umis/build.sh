#!/bin/bash
if [ `uname` == Darwin ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.9
fi
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
