#!/bin/sh
$PYTHON -m pip install -f https://pypi.org/simple/redis/ -vv redis
$PYTHON -m pip install -f https://pypi.org/simple/prettytable/ -vv prettytable
$PYTHON -m pip install -f https://pypi.org/simple/python-igraph/ -vv python-igraph 
$PYTHON -m pip install -f https://pypi.org/simple/gremlinpython/ -vv gremlinpython
$PYTHON -m pip install -f https://pypi.org/simple/redisgraph/ -vv redisgraph
$PYTHON -m pip install -f https://pypi.org/simple/texttable/ -vv texttable
$PYTHON -m pip install . -vv
