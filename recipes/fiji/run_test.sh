#!/bin/bash

set -xe

JARDIR=../share/jars
PLUGINSDIR=../share/plugins

echo -n 'Testing ImageJ with default memory settings...'
ImageJ --ij2 --headless --debug --jython hello.py | grep Bjoern
echo PASS
echo -n 'Testing ImageJ with specified memory settings...'
ImageJ --ij2 --headless --debug --heap 1g --jython hello.py | grep "\-Xmx1024m"
echo PASS
echo
echo "ALL TESTS PASSED"

