#!/bin/bash

JARFILE="$(dirname $(readlink -f "$0"))/metexplore2sbml.jar"

# no arguments : print help
if [[ $# -eq 0 ]]; then
    java -jar $JARFILE -h
else
    exec java -jar $JARFILE $@
fi;
