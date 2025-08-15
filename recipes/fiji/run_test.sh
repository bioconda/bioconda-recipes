#!/bin/bash

UNAME_S=$(uname -s)

# test only linux-64.
# linux-aarch64 build requires GLIBC_2.34 that is not available in the test container
if [ "${UNAME_S}" == "x86_64" ]; then

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

fi