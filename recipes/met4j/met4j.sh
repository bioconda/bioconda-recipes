#!/bin/bash

JARFILE="$(dirname $(readlink -f "$0"))/met4j-toolbox.jar"

function printUsageAndHelp(){
    echo ""
    echo "Usage: met4j [package.function] [options]"
    echo "  example : met4j fr.inrae.toulouse.metexplore.met4j_toolbox.convert.Sbml2Graph -i mySbml.xml -o ./output.txt"
    echo ""
    echo '-------------------------------------------'
    exec java -jar $JARFILE
}

# no arguments
if [[ $# -eq 0 ]]; then
    printUsageAndHelp
fi;

if (echo $1 | grep '^-' &> /dev/null); then
    # first argument is an option
    echo "First argument is not a valid package name : $1"
    echo ""
    printUsageAndHelp
else
    exec java -cp $JARFILE "$@"
fi;
