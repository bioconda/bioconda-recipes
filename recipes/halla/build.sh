#!/bin/bash

PYVER=`python -V | cut -f 2 -d " " | cut -f 1 -d "."`  # Returns the python major version
if [ ${PYVER} -eq 3 ]
then
	for i in halla/*.py
	do
		2to3 --write ${i}
	done
fi

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation
