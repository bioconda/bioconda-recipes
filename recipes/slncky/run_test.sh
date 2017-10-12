#!/bin/bash
slncky --help > /dev/null 2>&1 && test -d $PREFIX/annotations
exit $?
