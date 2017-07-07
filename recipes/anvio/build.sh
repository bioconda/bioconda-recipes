#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

# modify the requirements to allow cherrypy 8.x, since 8.9.1 is not in conda
perl -i -pe 's/^cherrypy.+/cherrypy>=8.0,<=8.9.1/' requirements.txt

$PYTHON setup.py install 

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
