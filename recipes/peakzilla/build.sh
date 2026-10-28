#!/bin/bash

mkdir -p ${PREFIX}/bin

if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w -n peakzilla.py
	cp peakzilla.py ${PREFIX}/bin
else
	cp peakzilla.py ${PREFIX}/bin
fi

chmod +x ${PREFIX}/bin/peakzilla.py
