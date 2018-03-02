#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

# modify the requirements to allow cherrypy 8.x, since 8.9.1 is not in conda
cp requirements.txt requirements.orig.txt
grep -v cherrypy requirements.orig.txt > requirements.txt
echo "cherrypy>=8.0,<=8.9.1" >> requirements.txt

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
