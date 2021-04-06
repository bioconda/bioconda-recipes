#!/bin/sh
$PYTHON -m pip install -f https://pypi.org/simple/gremlinpython/ -vv gremlinpython
$PYTHON -m pip install -f https://pypi.org/simple/redisgraph/ -vv redisgraph
$PYTHON -m pip install . -vv
