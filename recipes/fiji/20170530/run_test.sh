#!/bin/bash

set -e

JARDIR=../share/jars
PLUGINSDIR=../share/plugins

echo -n 'Testing ImageJ with default memory settings...'
ImageJ --ij2 --headless --debug --jython hello.py | grep Bjoern
echo PASS
echo -n 'Testing ImageJ with specified memory settings...'
ImageJ --ij2 --headless --debug -DXms=512m -DXmx=1g --jython hello.py | grep Bjoern
echo PASS
echo
echo "ALL TESTS PASSED"

